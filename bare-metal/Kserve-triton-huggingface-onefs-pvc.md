# The prowess of Dell PowerScale

![image](https://github.com/user-attachments/assets/b06ea771-4cf7-45ab-bd24-f06bd40f7161)

Ensure you are on the machine where you can access the cluster via kubectl and also has the model_repository downloaded locally
### Deploy Dell PowerScale CSI driver and Storage class
```
export csiReleaseNumber=2.10.0
export powerScaleClusterName=F900-AI
export userNameOfPowerScaleCluster=root
export ipOrFqdnOfPowerScaleCluster=172.29.208.91
export passwordOfPowerScaleCluster=XXXXX


eksdistroversion=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
export eksdistroversion

#CLONE THE POWERSCALE CSI REPO
rm -rf csi-powerscale
mkdir -p csi-powerscale
cd csi-powerscale
git clone --quiet -c advice.detachedHead=false -b csi-isilon-$csiReleaseNumber https://github.com/dell/helm-charts

#MODIFY VOLUME PREFIXES
sed -i "s/^volumeNamePrefix:.*/volumeNamePrefix:\ $clusterName/g" helm-charts/charts/csi-isilon/values.yaml
sed -i "s/snapNamePrefix: snapshot/snapNamePrefix: $clusterName-snap/g" helm-charts/charts/csi-isilon/values.yaml
sed -i 's/isiAuthType: 0/isiAuthType: 1/g' helm-charts/charts/csi-isilon/values.yaml

#MODIFY K8S VERSION IN THE HELM CHART TO CUSTOM VALUE USED BY EKS DISTRO
sed -i "s/^kubeVersion.*/kubeVersion: \"${eksdistroversion}\"/g" helm-charts/charts/csi-isilon/Chart.yaml

#PREPARE FOR POWERSCALE CSI INSTALLATION
kubectl create namespace csi-powerscale
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerscale/powerscale-creds.yaml
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerscale/emptysecret.yaml

#BUILD CREDS FILE FOR POWERSCALE CSI
sed -i "s/powerscale_cluster_name/$powerScaleClusterName/g" powerscale-creds.yaml
sed -i "s/powerscale_username/$userNameOfPowerScaleCluster/g" powerscale-creds.yaml
sed -i "s/powerscale_password/$passwordOfPowerScaleCluster/g" powerscale-creds.yaml
sed -i "s/powerscale_endpoint/$ipOrFqdnOfPowerScaleCluster/g" powerscale-creds.yaml

#CREATE SECRETS FOR POWERSCALE CSI
kubectl create secret generic isilon-creds -n csi-powerscale --from-file=config=powerscale-creds.yaml -o yaml --dry-run=client | kubectl apply -f -
kubectl create -f emptysecret.yaml

#INSTALL POWERSCALE CSI
cd helm-charts/charts
helm install isilon -n csi-powerscale csi-isilon/ --values csi-isilon/values.yaml

#CREATE STORAGE CLASS FOR POWERSCALE CSI
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerscale/powerscale-storageclass.yaml
kubectl create -f powerscale-storageclass.yaml
```
### Validate the CSI driver and storage class
```
kubectl get pods -n csi-powerscale
kubectl get sc
```
### Create the Persitent volume dynamically via PVC
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
  labels:
    name: task-pv-claim
    csi: powerscale
spec:
  storageClassName: powerscale
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 4Gi
EOF
```
### Create a Pod to copy the model_repository to the Persistent volume
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: model-store-pod
spec:
  volumes:
    - name: model-store
      persistentVolumeClaim:
        claimName: task-pv-claim
  containers:
    - name: model-store
      image: ubuntu
      command: [ "sleep" ]
      args: [ "infinity" ]
      volumeMounts:
        - mountPath: "/pv"
          name: model-store
      resources:
        limits:
          memory: "1Gi"
          cpu: "1"
EOF
```
### Copy the model_repository to the Pod that further maps it to the persistent volume
```
kubectl cp model_repository model-store-pod:/pv/ -c model-store
kubectl exec -it model-store-pod -- bash
```
### Create the Kserve Inference service with the Storage URL pointing to the existing PVC
```
cat <<EOF | kubectl apply -f -
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: huggingface-triton
spec:
  predictor:
    model:
      args:
      - --log-verbose=1
      modelFormat:
        name: triton
      protocolVersion: v2
      resources:
        limits:
          cpu: "1"
          memory: 8Gi
          nvidia.com/gpu: "1"
        requests:
          cpu: "1"
          memory: 8Gi
          nvidia.com/gpu: "1"
      runtimeVersion: 23.10-py3
      storageUri: "pvc://task-pv-claim/model_repository"
  transformer:
    containers:
    - args:
      - --model_name=bert
      - --model_id=bert-base-uncased
      - --predictor_protocol=v2
      - --tensor_input_names=input_ids
      image: kserve/huggingfaceserver:v0.13.1
      name: kserve-container
      resources:
        limits:
          cpu: "1"
          memory: 2Gi
        requests:
          cpu: 100m
          memory: 2Gi
EOF
```
### Validate
```
MODEL_NAME=bert
SERVICE_HOSTNAME=$(kubectl get inferenceservice huggingface-triton -o jsonpath='{.status.url}' | cut -d "/" -f 3)
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

curl -H "content-type:application/json" -H "Host: ${SERVICE_HOSTNAME}" -v http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/${MODEL_NAME}:predict -d '{"instances": ["The capital of france is [MASK]."] }' | jq .
```


