Ensure you are on the machine where you can access the cluster via kubectl and also has the model_repository downloaded locally
```
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/refs/heads/main/powerscale/install-powerscale-csi-driver.sh
chmod +x install-powerscale-csi-driver.sh
./install-powerscale-csi-driver.sh
```
Validate the CSI driver and storage class
```
kubectl get pods -n csi-powerscale
kubectl get sc
```
Create the Persitent volume dynamically via PVC
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
Create a Pod to copy the model_repository to the Persistent volume
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
Copy the model_repository to the Pod that further maps it to the persistent volume
```
kubectl cp model_repository model-store-pod:/pv/ -c model-store
kubectl exec -it model-store-pod -- bash
```
Create the Kserve Inference service with the Storage URL pointing to the existing PVC
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
Validate
```
MODEL_NAME=bert
SERVICE_HOSTNAME=$(kubectl get inferenceservice huggingface-triton -o jsonpath='{.status.url}' | cut -d "/" -f 3)
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

curl -H "content-type:application/json" -H "Host: ${SERVICE_HOSTNAME}" -v http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/${MODEL_NAME}:predict -d '{"instances": ["The capital of france is [MASK]."] }' | jq .
```


