![image](https://github.com/user-attachments/assets/35590bff-5fdb-44e0-bf02-27880fd77746)


Deploy Dell PowerScale CSI drivers and Storage Class
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

#PATCH STORAGE CLASS AS DEFAULT
kubectl patch storageclass powerscale -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

Install Homebrew
```
wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
chmod +x install.sh
#NOTE HOW WE ARE PASSING AN ENTER FOR THE INTERACTIVE PROMPT THAT THE INSTALL SCRIPT GENERATES TO CONFIRM FOR INSTALLATION
sudo echo -ne '\n' | ./install.sh
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/prd/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```
Install Kustomize
```
brew install kustomize
```
Install NVIDIA GPU Operator
```
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator
kubectl get pods -n gpu-operator
kubectl get node -o json | jq '.items[].metadata.labels'
```
Install and Configure MetalLB
```
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb --wait --timeout 15m --namespace metallb-system --create-namespace
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.29.198.75-172.29.198.76
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF
```
Install KubeFlow
```
git clone https://github.com/kubeflow/manifests.git
cd manifests
while ! kustomize build  example | kubectl apply -f - --server-side --force-conflicts; do echo "Retrying to apply resources"; sleep 10; done
```
Accessing Kubeflow using Port Forward
```
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
http://127.0.0.1:8080
Default credentials- user@example.com and 12341234
```
Accessing Kubeflow via Istio External IP
```
# PATCH THE SERVICE TYPE FOR ISTIO INGRESS GATEWAY
kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec": {"type": "LoadBalancer"}}'
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# CREATE A CERTIFICATE
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: istio-ingressgateway-certs
  namespace: istio-system
spec:
  commonName: istio-ingressgateway.istio-system.svc
  # Use ipAddresses if your LoadBalancer issues an IP
  ipAddresses:
  - $INGRESS_HOST
  # Use dnsNames if your LoadBalancer issues a hostname (eg DNS name from Civo dashboard)
  isCA: true
  issuerRef:
    kind: ClusterIssuer
    name: kubeflow-self-signing-issuer
  secretName: istio-ingressgateway-certs
EOF

# EDIT THE INGRESS GATEWAY OBJECT FOR KUBEFLOW-GATEWAY AND REPLACE THE VALUES STARTING FROM SPEC BLOCK
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: kubeflow-gateway
  namespace: kubeflow
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - '*'
    port:
      name: https
      number: 443
      protocol: HTTPS
    tls:
      mode: SIMPLE
      privateKey: /etc/istio/ingressgateway-certs/tls.key
      serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
EOF

# ACCESS KUBEFLOW DASHBOARD VIA HTTPS
https://<external-ip-of-istio-ingress-gateway>
Default credentials- user@example.com and 12341234
```
- Launch an instance with tensorflow image
- Create a notebook
```
import tensorflow as tf
print("Num GPUs Available: ", len(tf.config.experimental.list_physical_devices('GPU')))
```
Launch a terminal
```
pip install tensorflow-datasets
pip install tfds-nightly
```
Run the example notebook
```
https://www.tensorflow.org/datasets/keras_example
https://github.com/tensorflow/datasets/blob/master/docs/keras_example.ipynb
```
### Distributed Training

Scaling ML training involves the ability to increase the number of running workers/learners, CPUs/GPUs, or other compute resources available in the cluster. However, scaling Keras training jobs is not so straightforward because training an ML model with multiple workers requires a distributed strategy. It allows for substantially faster training iterations and speeds up ML experimentation and CI/CD pipelines, but building such a distributed strategy for ML training is hard because it can involve complex coordination between learners and aggregation of parameters. 

In general, there are two main approaches to distributed training popular in the ML community today: synchronous and asynchronous training. 

In synchronous distributed training, each worker processes its part of the training dataset. Workers also communicate with each other to process their part of the gradient and aggregate results. The most popular approach to synchronous training is based on all-reduce algorithms. 

Contrary to this, in asynchronous training, all learners work on the complete training data independently, updating parameters asynchronously. Async training is implemented via a parameter server architecture where parameter updates are aggregated and performed by a parameter server that coordinates the interactions between workers.

Generally a mixed bag of opinion in terms of what is better Asynchronous vs Synchronous in terms of performance/throughput. In sync training, all workers train over different slices of input data in sync, and aggregating gradients at each step. In async training, all workers are independently training over the input data and updating variables asynchronously. Typically sync training is supported via all-reduce and async through parameter server architecture. The final training result of async and sync parallel distributed training depends upon specific implementation, optimization, and training algorithm

#### Deploy the Training Operator
```
kubectl apply --server-side --force-conflicts -k "github.com/kubeflow/training-operator.git/manifests/overlays/standalone?ref=v1.8.0"
```
#### TFJob Asynchronous Distributed training using Parameter Server

- Start with 1 worker replica with 1 GPU and then consequently change the number of worker replicas/GPU based on capacity

```
cat <<EOF | kubectl apply -f -
apiVersion: "kubeflow.org/v1"
kind: "TFJob"
metadata:
  name: "tf-smoke-gpu"
spec:
  tfReplicaSpecs:
    PS:
      replicas: 1
      template:
        metadata:
          creationTimestamp: null
        spec:
          containers:
            - args:
                - python
                - tf_cnn_benchmarks.py
                - --batch_size=32
                - --model=resnet50
                - --variable_update=parameter_server
                - --flush_stdout=true
                - --num_gpus=1
                - --local_parameter_device=cpu
                - --device=cpu
                - --data_format=NHWC
              image: kubeflow/tf-benchmarks-cpu:v20171202-bdab599-dirty-284af3
              name: tensorflow
              ports:
                - containerPort: 2222
                  name: tfjob-port
              resources:
                limits:
                  cpu: "1"
              workingDir: /opt/tf-benchmarks/scripts/tf_cnn_benchmarks
          restartPolicy: OnFailure
    Worker:
      replicas: 2
      template:
        metadata:
          creationTimestamp: null
        spec:
          containers:
            - args:
                - python
                - tf_cnn_benchmarks.py
                - --batch_size=32
                - --model=resnet50
                - --variable_update=parameter_server
                - --flush_stdout=true
                - --num_gpus=1
                - --local_parameter_device=cpu
                - --device=gpu
                - --data_format=NHWC
              image: kubeflow/tf-benchmarks-gpu:v20171202-bdab599-dirty-284af3
              name: tensorflow
              ports:
                - containerPort: 2222
                  name: tfjob-port
              resources:
                limits:
                  nvidia.com/gpu: 1
              workingDir: /opt/tf-benchmarks/scripts/tf_cnn_benchmarks
          restartPolicy: OnFailure
EOF
```
- Observations
```
1 worker 1 GPU
INFO|2024-12-07T13:54:53|/opt/launcher.py|27| Step      Img/sec loss
INFO|2024-12-07T13:54:54|/opt/launcher.py|27| 1 images/sec: 79.5 +/- 0.0 (jitter = 0.0) 10.803
INFO|2024-12-07T13:54:57|/opt/launcher.py|27| 10        images/sec: 79.8 +/- 2.0 (jitter = 2.9) 8.642
INFO|2024-12-07T13:55:01|/opt/launcher.py|27| 20        images/sec: 81.0 +/- 1.3 (jitter = 3.0) 8.531
INFO|2024-12-07T13:55:05|/opt/launcher.py|27| 30        images/sec: 82.0 +/- 1.0 (jitter = 2.6) 8.038
INFO|2024-12-07T13:55:09|/opt/launcher.py|27| 40        images/sec: 81.9 +/- 1.0 (jitter = 2.9) 9.497
INFO|2024-12-07T13:55:13|/opt/launcher.py|27| 50        images/sec: 82.0 +/- 0.9 (jitter = 2.7) 7.858
INFO|2024-12-07T13:55:17|/opt/launcher.py|27| 60        images/sec: 82.7 +/- 0.9 (jitter = 3.4) 8.721
INFO|2024-12-07T13:55:20|/opt/launcher.py|27| 70        images/sec: 83.0 +/- 0.8 (jitter = 3.5) 8.039
INFO|2024-12-07T13:55:24|/opt/launcher.py|27| 80        images/sec: 82.8 +/- 0.7 (jitter = 3.4) 7.931
INFO|2024-12-07T13:55:28|/opt/launcher.py|27| 90        images/sec: 82.5 +/- 0.7 (jitter = 3.6) 7.806
INFO|2024-12-07T13:55:32|/opt/launcher.py|27| 100       images/sec: 82.1 +/- 0.7 (jitter = 3.4) 7.945
INFO|2024-12-07T13:55:32|/opt/launcher.py|27| ----------------------------------------------------------------
INFO|2024-12-07T13:55:32|/opt/launcher.py|27| total images/sec: 82.40
INFO|2024-12-07T13:55:32|/opt/launcher.py|27| ----------------------------------------------------------------

2 workers 1 GPU

INFO|2024-12-07T14:06:22|/opt/launcher.py|27| Step      Img/sec loss
INFO|2024-12-07T14:06:22|/opt/launcher.py|27| 1 images/sec: 78.1 +/- 0.0 (jitter = 0.0) 9.057
INFO|2024-12-07T14:06:25|/opt/launcher.py|27| 10        images/sec: 83.3 +/- 2.0 (jitter = 3.4) 8.282
INFO|2024-12-07T14:06:29|/opt/launcher.py|27| 20        images/sec: 83.9 +/- 1.9 (jitter = 5.0) 8.037
INFO|2024-12-07T14:06:33|/opt/launcher.py|27| 30        images/sec: 83.1 +/- 1.4 (jitter = 3.9) 7.929
INFO|2024-12-07T14:06:37|/opt/launcher.py|27| 40        images/sec: 83.0 +/- 1.2 (jitter = 3.8) 9.025
INFO|2024-12-07T14:06:41|/opt/launcher.py|27| 50        images/sec: 82.5 +/- 1.1 (jitter = 4.3) 7.934
INFO|2024-12-07T14:06:45|/opt/launcher.py|27| 60        images/sec: 82.8 +/- 1.0 (jitter = 4.3) 8.365
INFO|2024-12-07T14:06:48|/opt/launcher.py|27| 70        images/sec: 83.2 +/- 0.9 (jitter = 4.3) 7.904
INFO|2024-12-07T14:06:52|/opt/launcher.py|27| 80        images/sec: 83.3 +/- 0.8 (jitter = 4.5) 7.925
INFO|2024-12-07T14:06:56|/opt/launcher.py|27| 90        images/sec: 82.9 +/- 0.8 (jitter = 4.8) 7.929
INFO|2024-12-07T14:07:00|/opt/launcher.py|27| 100       images/sec: 83.3 +/- 0.8 (jitter = 4.7) 7.886
INFO|2024-12-07T14:07:00|/opt/launcher.py|27| ----------------------------------------------------------------
INFO|2024-12-07T14:07:00|/opt/launcher.py|27| total images/sec: 167.40
INFO|2024-12-07T14:07:00|/opt/launcher.py|27| ----------------------------------------------------------------
```

### PyTorchJob 
```
cat <<EOF | kubectl create -f -
apiVersion: "kubeflow.org/v1"
kind: "PyTorchJob"
metadata:
  name: "pytorchjob-mnist"
spec:
  pytorchReplicaSpecs:
    Master:
      replicas: 1
      restartPolicy: OnFailure
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "false"
        spec:
          containers:
            - name: pytorch
              image: docker.io/kubeflowkatib/pytorch-mnist-gpu:latest
              args:
                - --epochs
                - "20"
                - --seed
                - "7"
                - --log-interval
                - "256"
                - --batch-size
                - "512"
              resources:
                limits:
                  cpu: 1
                  memory: "3G"
                  nvidia.com/gpu: 1
    Worker:
      replicas: 2
      restartPolicy: OnFailure
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "false"
        spec:
          containers:
            - name: pytorch
              image: docker.io/kubeflowkatib/pytorch-mnist-gpu:latest
              args:
                - --epochs
                - "20"
                - --seed
                - "7"
                - --log-interval
                - "256"
                - --batch-size
                - "512"
              resources:
                limits:
                  cpu: 1
                  memory: "3G"
                  nvidia.com/gpu: 1
#  runPolicy:
#    ttlSecondsAfterFinished: 600
EOF
```
### Installing and configuring kubectl on windows
```
https://site-ghwmnxe1v6.talkyard.net/-12/faq-how-to-set-up-kubeconfig-on-windows-wise-paasensaas-k8s-service
```
### References
- https://www.kubeflow.org/docs/components/training/user-guides/tensorflow/
- https://iamondemand.com/blog/scaling-keras-on-kubernetes-with-kubeflow/#:~:text=Keras%20models%20deployed%20using%20Seldon,RAM%20load%20or%20network%20requests.
- https://kueue.sigs.k8s.io/docs/tasks/run/kubeflow/pytorchjobs/
- 
