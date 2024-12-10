![image](https://github.com/user-attachments/assets/35590bff-5fdb-44e0-bf02-27880fd77746)


Deploy Dell PowerScale CSI drivers and Storage Class
```
export passwordOfPowerScaleCluster=XXXXX
export csiReleaseNumber=2.10.0
export powerScaleClusterName=F900-AI
export userNameOfPowerScaleCluster=root
export ipOrFqdnOfPowerScaleCluster=172.29.208.91

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
apiVersion: cert-manager.io/v1
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

# EDIT THE INGRESS GATEWAY OBJECT FOR KUBEFLOW-GATEWAY AND REPLACE THE VALUES STARTING FROM SERVER BLOCK

KUBE_EDITOR="nano" kubectl edit -n kubeflow gateways.networking.istio.io kubeflow-gateway

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
```
### ACCESS KUBEFLOW DASHBOARD VIA HTTPS
```
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
#### Deploy the Training Operator
```
kubectl apply --server-side --force-conflicts -k "github.com/kubeflow/training-operator.git/manifests/overlays/standalone?ref=v1.8.0"
```
#### TensorFlow Distributed Training
![image](https://github.com/user-attachments/assets/6c14937c-8c08-43ee-af7d-21445f1f7b55)
Scaling ML training involves the ability to increase the number of running workers/learners, CPUs/GPUs, or other compute resources available in the cluster. However, scaling Keras training jobs is not so straightforward because training an ML model with multiple workers requires a distributed strategy. It allows for substantially faster training iterations and speeds up ML experimentation and CI/CD pipelines, but building such a distributed strategy for ML training is hard because it can involve complex coordination between learners and aggregation of parameters. 

In general, there are two main approaches to distributed training popular in the ML community today: synchronous and asynchronous training. 

In synchronous distributed training, each worker processes its part of the training dataset. Workers also communicate with each other to process their part of the gradient and aggregate results. The most popular approach to synchronous training is based on all-reduce algorithms. 

Contrary to this, in asynchronous training, all learners work on the complete training data independently, updating parameters asynchronously. Async training is implemented via a parameter server architecture where parameter updates are aggregated and performed by a parameter server that coordinates the interactions between workers.

Generally a mixed bag of opinion in terms of what is better Asynchronous vs Synchronous in terms of performance/throughput. In sync training, all workers train over different slices of input data in sync, and aggregating gradients at each step. In async training, all workers are independently training over the input data and updating variables asynchronously. Typically sync training is supported via all-reduce and async through parameter server architecture. The final training result of async and sync parallel distributed training depends upon specific implementation, optimization, and training algorithm


#### TFJob Asynchronous Distributed training using Parameter Server
![image](https://github.com/user-attachments/assets/10c94ded-2c69-4b31-a9c5-0b8344d7da92)

![image](https://github.com/user-attachments/assets/d50002e2-2a62-4a80-9e95-e2ce7f38a404)


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
#### TFJob Synchronous MultiWorker training for TensorFlow
```
export storageClassName=powerscale

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: strategy-volume
  labels:
    app: strategy-volume
spec:
  storageClassName: ${storageClassName}
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
EOF

cat <<EOF | kubectl create -f -
apiVersion: kubeflow.org/v1
kind: TFJob
metadata:
  name: multi-worker
spec:
  tfReplicaSpecs:
    Worker:
      replicas: 2
      restartPolicy: Never
      template:
        spec:
          containers:
            - name: tensorflow
              image: thecloudgarage/multi_worker_strategy:0.1.1
              volumeMounts:
                - mountPath: /train
                  name: training
              resources:
                limits:
                  nvidia.com/gpu: 1
          volumes:
            - name: training
              persistentVolumeClaim:
                claimName: strategy-volume
EOF
```

### PyTorchJob Distributed Training for PyTorch
![image](https://github.com/user-attachments/assets/c5acff3a-ea3c-4f64-8776-02f46e8330d0)

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
### WORK-IN-PROGRESS PyTorch FSDP to fine tune a LLAMA2 model
Having a replica of the model on each GPU restricts the size of the model that can be accommodated in a DDP workflow. FSDP helps overcome this limitation by sharding model parameters, optimizer states, and gradients across data parallel workers while still preserving the simplicity of data parallelism.

![image](https://github.com/user-attachments/assets/959310e8-52fe-405f-a23a-d1f3a8690c49)

```
kubectl apply -f https://raw.githubusercontent.com/aws-samples/aws-do-eks/main/Container-Root/eks/deployment/etcd/etcd-deployment.yaml

JOB_NAME=fsdp
RDZV_HOST=etcd
RDZV_PORT=2379
NUM_WORKERS=2
GPU_PER_WORKER=2
EFA_PER_WORKER=0
MODEL_NAME=meta-llama/Llama-2-7b-hf
HF_TOKEN="Your-huggingface-token"
CMD="huggingface-cli login --token ${HF_TOKEN} && torchrun --nproc_per_node=${GPU_PER_WORKER} --nnodes=${NUM_WORKERS} recipes/finetuning/finetuning.py --num_epochs=3 --batch_size_training=3 --enable_fsdp --model_name $MODEL_NAME --output_dir ."
DOCKERHUB_USER_NAME=thecloudgarage
IMAGE=fsdp
TAG=":llama2"

cat > ./Dockerfile <<EOF
FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime
#FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y git vim curl htop
RUN mkdir -p /workspace/
WORKDIR /workspace
RUN git clone -b aws-do-fsdp  https://github.com/meta-llama/llama-recipes.git
WORKDIR /workspace/llama-recipes
RUN pip3 install -U pip setuptools
RUN pip3 install fsspec==2023.1.0
RUN pip3 install huggingface_hub==0.17.0
RUN pip3 install -r requirements.txt
RUN pip3 install -e .
RUN pip3 install tabulate
# The following two lines can be used to switch to the nighhtly pytorch build if needed
#RUN pip3 uninstall -y torch
#RUN pip3 install --pre torch --index-url https://download.pytorch.org/whl/nightly/cu121
RUN pip3 install protobuf
RUN rm -rf /root/.cache
RUN apt-get clean
ENV PYTHONPATH="/workspace/llama-recipes/src"
RUN pip3 install awscli pynvml python-etcd
EOF


docker built -t $DOCKERHUB_USER_NAME/${IMAGE}${TAG}
docker image push $DOCKERHUB_USER_NAME/${IMAGE}${TAG}

cat > ./fsdp.yaml <<EOF
apiVersion: kubeflow.org/v1
kind: PyTorchJob
metadata:
  name: $JOB_NAME
spec:
  elasticPolicy:
    rdzvBackend: etcd
    rdzvHost: $RDZV_HOST
    rdzvPort: $RDZV_PORT
    rdzvId: '1' #ENSURE THIS VALUE IS CHANGED EVERY TIME YOU REDEPLOY
    minReplicas: 1
    maxReplicas: 4
    maxRestarts: 100
    metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 90
  pytorchReplicaSpecs:
    Worker:
      replicas: $NUM_WORKERS
      restartPolicy: OnFailure
      template:
        metadata:
          labels:
            app: $JOB_NAME
        spec:
          volumes:
            - name: shmem
              hostPath:
                path: /dev/shm
          nodeSelector:
            gputype: 'l40s'
          containers:
            - name: pytorch
              image: '$DOCKERHUB_USER_NAME/${IMAGE}${TAG}'
              imagePullPolicy: Always
              resources:
                requests:
                  nvidia.com/gpu: 2
                limits:
                  nvidia.com/gpu: 2
              env:
                - name: LOGLEVEL
                  value: DEBUG
                - name: NCCL_DEBUG
                  value: INFO
                - name: TORCH_NCCL_ASYNC_ERROR_HANDLING
                  value: '1'
                - name: CUDA_VISIBLE_DEVICES
                  value: '0,1'
              command:
                - bash
                - '-c'
                - '${CMD}'
              volumeMounts:
                - name: shmem
                  mountPath: /dev/shm
EOF
```
NOTE: Before the epochs start one might notice the below error and it's harmless

This message

NET/Plugin : dlerror=libnccl-net.so: cannot open shared object file: No such file or directory No plugin found (libnccl-net.so), using internal implementation

is harmless. It just means that NCCL did not find an external network plugin (e.g. to support IB/SHARP).
It defaults back to its internal plugin, which supports IB Verbs, RoCE and Sockets.

LOGS
```
kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
etcd-6bcc78d587-s57jp   1/1     Running   0          4h22m
fsdp-worker-0           1/1     Running   0          27m
fsdp-worker-1           1/1     Running   0          27m
[prd@csctmp-r760-18 fsdp-test]$
[prd@csctmp-r760-18 fsdp-test]$
[prd@csctmp-r760-18 fsdp-test]$
[prd@csctmp-r760-18 fsdp-test]$
[prd@csctmp-r760-18 fsdp-test]$ kubectl logs fsdp-worker-1
The token has not been saved to the git credentials helper. Pass `add_to_git_credential=True` in this function directly or `--add-to-git-credential` if using via `huggingface-cli` if you want to set the git credential as well.
Token is valid (permission: fineGrained).
The token `t2` has been saved to /root/.cache/huggingface/stored_tokens
Your token has been saved to /root/.cache/huggingface/token
Login successful.
The current active token is: `t2`
W1210 18:28:00.405000 1 site-packages/torch/distributed/run.py:793]
W1210 18:28:00.405000 1 site-packages/torch/distributed/run.py:793] *****************************************
W1210 18:28:00.405000 1 site-packages/torch/distributed/run.py:793] Setting OMP_NUM_THREADS environment variable for each process to be 1 in default, to avoid your system being overloaded, please further tune the variable for optimal performance in your application as needed.
W1210 18:28:00.405000 1 site-packages/torch/distributed/run.py:793] *****************************************
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194] Starting elastic_operator with launch configs:
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   entrypoint       : recipes/finetuning/finetuning.py
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   min_nodes        : 2
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   max_nodes        : 2
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   nproc_per_node   : 2
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   run_id           : 1
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   rdzv_backend     : etcd
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   rdzv_endpoint    : etcd:2379
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   rdzv_configs     : {'timeout': 900}
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   max_restarts     : 100
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   monitor_interval : 0.1
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   log_dir          : /tmp/torchelastic_4tl8luxn
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]   metrics_cfg      : {}
I1210 18:28:00.405000 1 site-packages/torch/distributed/launcher/api.py:194]
INFO 2024-12-10 18:28:00,562 Etcd machines: ['http://0.0.0.0:2379']
I1210 18:28:00.568000 1 site-packages/torch/distributed/elastic/agent/server/api.py:845] [default] starting workers for entrypoint: python3.11
I1210 18:28:00.569000 1 site-packages/torch/distributed/elastic/agent/server/api.py:662] [default] Rendezvous'ing worker group
INFO 2024-12-10 18:28:00,569 Attempting to join next rendezvous
INFO 2024-12-10 18:28:00,574 New rendezvous state created: {'status': 'joinable', 'version': '1', 'participants': []}
INFO 2024-12-10 18:28:00,591 Joined rendezvous version 1 as rank 0. Full state: {'status': 'joinable', 'version': '1', 'participants': [0]}
INFO 2024-12-10 18:28:00,591 Waiting for remaining peers.
INFO 2024-12-10 18:28:01,708 All peers arrived. Confirming membership.
INFO 2024-12-10 18:28:01,745 Waiting for confirmations from all peers.
INFO 2024-12-10 18:28:01,774 Rendezvous version 1 is complete. Final state: {'status': 'final', 'version': '1', 'participants': [0, 1], 'keep_alives': ['/torchelastic/p2p/run_1/rdzv/v_1/rank_0', '/torchelastic/p2p/run_1/rdzv/v_1/rank_1'], 'num_workers_waiting': 0}
INFO 2024-12-10 18:28:01,774 Creating EtcdStore as the c10d::Store implementation
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525] [default] Rendezvous complete for workers. Result:
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]   restart_count=0
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]   master_addr=fsdp-worker-1
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]   master_port=39765
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]   group_rank=0
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]   group_world_size=2
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]   local_ranks=[0, 1]
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]   role_ranks=[0, 1]
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]   global_ranks=[0, 1]
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]   role_world_sizes=[4, 4]
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]   global_world_sizes=[4, 4]
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:525]
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/api.py:670] [default] Starting worker group
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/local_elastic_agent.py:291] use_agent_store: False
I1210 18:28:01.790000 1 site-packages/torch/distributed/elastic/agent/server/local_elastic_agent.py:192] Environment variable 'TORCHELASTIC_ENABLE_FILE_TIMER' not found. Do not start FileTimerServer.
I1210 18:28:01.791000 1 site-packages/torch/distributed/elastic/agent/server/local_elastic_agent.py:229] Environment variable 'TORCHELASTIC_HEALTH_CHECK_PORT' not found. Do not start health check.
/workspace/llama-recipes/src/llama_recipes/model_checkpointing/checkpoint_handler.py:17: DeprecationWarning: `torch.distributed._shard.checkpoint` will be deprecated, use `torch.distributed.checkpoint` instead
  from torch.distributed._shard.checkpoint import (
/workspace/llama-recipes/src/llama_recipes/model_checkpointing/checkpoint_handler.py:17: DeprecationWarning: `torch.distributed._shard.checkpoint` will be deprecated, use `torch.distributed.checkpoint` instead
  from torch.distributed._shard.checkpoint import (
Clearing GPU cache for all ranks
--> Running with torch dist debug set to detail
Downloading shards: 100%|██████████| 2/2 [10:16<00:00, 308.42s/it]
Downloading shards: 100%|██████████| 2/2 [10:17<00:00, 308.89s/it]
Loading checkpoint shards: 100%|██████████| 2/2 [00:05<00:00,  2.52s/it]
Loading checkpoint shards: 100%|██████████| 2/2 [00:05<00:00,  2.52s/it]
--> Model meta-llama/Llama-2-7b-hf

--> meta-llama/Llama-2-7b-hf has 6738.415616 Million params

bFloat16 enabled for mixed precision - using bfSixteen policy
--> applying fsdp activation checkpointing...
--> applying fsdp activation checkpointing...
Generating train split: 100%|██████████| 14732/14732 [00:00<00:00, 44079.11 examples/s]
Generating test split: 100%|██████████| 819/819 [00:00<00:00, 5505.54 examples/s]
Generating validation split: 100%|██████████| 818/818 [00:00<00:00, 5580.25 examples/s]
Map: 100%|██████████| 14732/14732 [00:00<00:00, 43608.68 examples/s]
Map: 100%|██████████| 14732/14732 [00:00<00:00, 43310.93 examples/s]
Map: 100%|██████████| 14732/14732 [00:09<00:00, 1508.06 examples/s]
--> Training Set Length = 14732
Map: 100%|██████████| 14732/14732 [00:09<00:00, 1504.38 examples/s]
Map: 100%|██████████| 818/818 [00:00<00:00, 37561.48 examples/s]
Map: 100%|██████████| 818/818 [00:00<00:00, 1525.76 examples/s]
Map: 100%|██████████| 818/818 [00:00<00:00, 1522.25 examples/s]]
--> Validation Set Length = 818
Preprocessing dataset: 100%|██████████| 14732/14732 [00:02<00:00, 5587.46it/s]
Preprocessing dataset: 100%|██████████| 14732/14732 [00:02<00:00, 5506.40it/s]
Preprocessing dataset: 100%|██████████| 818/818 [00:00<00:00, 5783.29it/s]
Preprocessing dataset: 100%|██████████| 818/818 [00:00<00:00, 5372.98it/s]
/opt/conda/lib/python3.11/site-packages/torch/cuda/memory.py:365: FutureWarning: torch.cuda.reset_max_memory_allocated now calls torch.cuda.reset_peak_memory_stats, which resets /all/ peak memory stats.
  warnings.warn(
Training Epoch: 1:   0%|          | 0/64 [00:00<?, ?it/s]/opt/conda/lib/python3.11/site-packages/torch/cuda/memory.py:365: FutureWarning: torch.cuda.reset_max_memory_allocated now calls torch.cuda.reset_peak_memory_stats, which resets /all/ peak memory stats.
  warnings.warn(
fsdp-worker-1:73:73 [0] NCCL INFO Bootstrap : Using eth0:192.168.1.136<0>
fsdp-worker-1:73:73 [0] NCCL INFO NET/Plugin: No plugin found (libnccl-net.so)
fsdp-worker-1:73:73 [0] NCCL INFO NET/Plugin: Plugin load returned 2 : libnccl-net.so: cannot open shared object file: No such file or directory : when loading libnccl-net.so
fsdp-worker-1:73:73 [0] NCCL INFO NET/Plugin: Using internal network plugin.
fsdp-worker-1:73:73 [0] NCCL INFO cudaDriverVersion 12040
NCCL version 2.21.5+cuda12.4
fsdp-worker-1:74:74 [1] NCCL INFO cudaDriverVersion 12040
fsdp-worker-1:74:74 [1] NCCL INFO Bootstrap : Using eth0:192.168.1.136<0>
fsdp-worker-1:74:74 [1] NCCL INFO NET/Plugin: No plugin found (libnccl-net.so)
fsdp-worker-1:74:74 [1] NCCL INFO NET/Plugin: Plugin load returned 2 : libnccl-net.so: cannot open shared object file: No such file or directory : when loading libnccl-net.so
fsdp-worker-1:74:74 [1] NCCL INFO NET/Plugin: Using internal network plugin.
fsdp-worker-1:73:356 [0] NCCL INFO Failed to open libibverbs.so[.1]
fsdp-worker-1:73:356 [0] NCCL INFO NET/Socket : Using [0]eth0:192.168.1.136<0>
fsdp-worker-1:73:356 [0] NCCL INFO Using non-device net plugin version 0
fsdp-worker-1:73:356 [0] NCCL INFO Using network Socket
fsdp-worker-1:74:357 [1] NCCL INFO Failed to open libibverbs.so[.1]
fsdp-worker-1:74:357 [1] NCCL INFO NET/Socket : Using [0]eth0:192.168.1.136<0>
fsdp-worker-1:74:357 [1] NCCL INFO Using non-device net plugin version 0
fsdp-worker-1:74:357 [1] NCCL INFO Using network Socket
fsdp-worker-1:74:357 [1] NCCL INFO ncclCommInitRank comm 0x56169dab8e50 rank 1 nranks 4 cudaDev 1 nvmlDev 1 busId b5000 commId 0x89739f751af3a52d - Init START
fsdp-worker-1:73:356 [0] NCCL INFO ncclCommInitRank comm 0x56340ebcd160 rank 0 nranks 4 cudaDev 0 nvmlDev 0 busId d000 commId 0x89739f751af3a52d - Init START
fsdp-worker-1:74:357 [1] NCCL INFO Setting affinity for GPU 1 to aaaaaaaa,aaaaaaaa
fsdp-worker-1:73:356 [0] NCCL INFO Setting affinity for GPU 0 to 55555555,55555555
fsdp-worker-1:74:357 [1] NCCL INFO comm 0x56169dab8e50 rank 1 nRanks 4 nNodes 2 localRanks 2 localRank 1 MNNVL 0
fsdp-worker-1:74:357 [1] NCCL INFO Trees [0] -1/-1/-1->1->0 [1] -1/-1/-1->1->0
fsdp-worker-1:74:357 [1] NCCL INFO P2P Chunksize set to 131072
fsdp-worker-1:73:356 [0] NCCL INFO comm 0x56340ebcd160 rank 0 nRanks 4 nNodes 2 localRanks 2 localRank 0 MNNVL 0
fsdp-worker-1:73:356 [0] NCCL INFO Channel 00/02 :    0   1   2   3
fsdp-worker-1:73:356 [0] NCCL INFO Channel 01/02 :    0   1   2   3
fsdp-worker-1:73:356 [0] NCCL INFO Trees [0] 1/2/-1->0->-1 [1] 1/-1/-1->0->2
fsdp-worker-1:73:356 [0] NCCL INFO P2P Chunksize set to 131072
fsdp-worker-1:73:356 [0] NCCL INFO Channel 00/0 : 3[1] -> 0[0] [receive] via NET/Socket/0
fsdp-worker-1:73:356 [0] NCCL INFO Channel 01/0 : 3[1] -> 0[0] [receive] via NET/Socket/0
fsdp-worker-1:73:356 [0] NCCL INFO Channel 00 : 0[0] -> 1[1] via SHM/direct/direct
fsdp-worker-1:73:356 [0] NCCL INFO Channel 01 : 0[0] -> 1[1] via SHM/direct/direct
fsdp-worker-1:74:357 [1] NCCL INFO Channel 00/0 : 1[1] -> 2[0] [send] via NET/Socket/0
fsdp-worker-1:74:357 [1] NCCL INFO Channel 01/0 : 1[1] -> 2[0] [send] via NET/Socket/0
fsdp-worker-1:73:356 [0] NCCL INFO Connected all rings
fsdp-worker-1:73:356 [0] NCCL INFO Channel 00/0 : 2[0] -> 0[0] [receive] via NET/Socket/0
fsdp-worker-1:73:356 [0] NCCL INFO Channel 01/0 : 2[0] -> 0[0] [receive] via NET/Socket/0
fsdp-worker-1:73:356 [0] NCCL INFO Channel 00/0 : 0[0] -> 2[0] [send] via NET/Socket/0
fsdp-worker-1:73:356 [0] NCCL INFO Channel 01/0 : 0[0] -> 2[0] [send] via NET/Socket/0
fsdp-worker-1:74:357 [1] NCCL INFO Connected all rings
fsdp-worker-1:74:357 [1] NCCL INFO Channel 00 : 1[1] -> 0[0] via SHM/direct/direct
fsdp-worker-1:74:357 [1] NCCL INFO Channel 01 : 1[1] -> 0[0] via SHM/direct/direct
fsdp-worker-1:74:357 [1] NCCL INFO Connected all trees
fsdp-worker-1:74:357 [1] NCCL INFO threadThresholds 8/8/64 | 32/8/64 | 512 | 512
fsdp-worker-1:74:357 [1] NCCL INFO 2 coll channels, 2 collnet channels, 0 nvls channels, 2 p2p channels, 2 p2p channels per peer
fsdp-worker-1:73:356 [0] NCCL INFO Connected all trees
fsdp-worker-1:73:356 [0] NCCL INFO threadThresholds 8/8/64 | 32/8/64 | 512 | 512
fsdp-worker-1:73:356 [0] NCCL INFO 2 coll channels, 2 collnet channels, 0 nvls channels, 2 p2p channels, 2 p2p channels per peer
fsdp-worker-1:74:357 [1] NCCL INFO TUNER/Plugin: Plugin load returned 2 : libnccl-net.so: cannot open shared object file: No such file or directory : when loading libnccl-tuner.so
fsdp-worker-1:74:357 [1] NCCL INFO TUNER/Plugin: Using internal tuner plugin.
fsdp-worker-1:74:357 [1] NCCL INFO ncclCommInitRank comm 0x56169dab8e50 rank 1 nranks 4 cudaDev 1 nvmlDev 1 busId b5000 commId 0x89739f751af3a52d - Init COMPLETE
fsdp-worker-1:73:356 [0] NCCL INFO TUNER/Plugin: Plugin load returned 2 : libnccl-net.so: cannot open shared object file: No such file or directory : when loading libnccl-tuner.so
fsdp-worker-1:73:356 [0] NCCL INFO TUNER/Plugin: Using internal tuner plugin.
fsdp-worker-1:73:356 [0] NCCL INFO ncclCommInitRank comm 0x56340ebcd160 rank 0 nranks 4 cudaDev 0 nvmlDev 0 busId d000 commId 0x89739f751af3a52d - Init COMPLETE
Training Epoch: 1/3, step 63/64 completed (loss: 1.088591456413269): 100%|██████████| 64/64 [13:23<00:00, 12.56s/it]
Training Epoch: 1/3, step 63/64 completed (loss: 1.0633320808410645): 100%|██████████| 64/64 [13:23<00:00, 12.55s/it]
Max CUDA memory allocated was 31 GB
Max CUDA memory reserved was 42 GB
Peak active CUDA memory was 35 GB
CUDA Malloc retries : 0
CPU Total Peak Memory consumed during the train (max): 3 GB
evaluating Epoch: 100%|██████████| 11/11 [00:44<00:00,  4.05s/it]
evaluating Epoch: 100%|██████████| 11/11 [00:44<00:00,  4.05s/it]
 eval_ppl=tensor(2.8432, device='cuda:0') eval_epoch_loss=tensor(1.0449, device='cuda:0')
 Saving the FSDP model checkpoints using SHARDED_STATE_DICT
===================================================== Saving the FSDP model checkpoints using SHARDED_STATE_DICT

=====================================================
Saving model to /workspace/llama-recipes/PATH/to/save/FSDP/model/fine-tuned-meta-llama/Llama-2-7b-hf
/opt/conda/lib/python3.11/site-packages/torch/distributed/fsdp/fully_sharded_data_parallel.py:690: FutureWarning: FSDP.state_dict_type() and FSDP.set_state_dict_type() are being deprecated. Please use APIs, get_state_dict() and set_state_dict(), which can support different parallelisms, FSDP1, FSDP2, DDP. API doc: https://pytorch.org/docs/stable/distributed.checkpoint.html#torch.distributed.checkpoint.state_dict.get_state_dict .Tutorial: https://pytorch.org/tutorials/recipes/distributed_checkpoint_recipe.html .
  warnings.warn(
/opt/conda/lib/python3.11/site-packages/torch/distributed/fsdp/fully_sharded_data_parallel.py:690: FutureWarning: FSDP.state_dict_type() and FSDP.set_state_dict_type() are being deprecated. Please use APIs, get_state_dict() and set_state_dict(), which can support different parallelisms, FSDP1, FSDP2, DDP. API doc: https://pytorch.org/docs/stable/distributed.checkpoint.html#torch.distributed.checkpoint.state_dict.get_state_dict .Tutorial: https://pytorch.org/tutorials/recipes/distributed_checkpoint_recipe.html .
  warnings.warn(
/opt/conda/lib/python3.11/site-packages/torch/distributed/fsdp/_state_dict_utils.py:732: FutureWarning: Please use DTensor instead and we are deprecating ShardedTensor.
  local_shape = tensor.shape
/opt/conda/lib/python3.11/site-packages/torch/distributed/fsdp/_state_dict_utils.py:744: FutureWarning: Please use DTensor instead and we are deprecating ShardedTensor.
  tensor.shape,
/opt/conda/lib/python3.11/site-packages/torch/distributed/fsdp/_state_dict_utils.py:746: FutureWarning: Please use DTensor instead and we are deprecating ShardedTensor.
  tensor.dtype,
/opt/conda/lib/python3.11/site-packages/torch/distributed/fsdp/_state_dict_utils.py:747: FutureWarning: Please use DTensor instead and we are deprecating ShardedTensor.
  tensor.device,
/opt/conda/lib/python3.11/site-packages/torch/distributed/fsdp/_state_dict_utils.py:732: FutureWarning: Please use DTensor instead and we are deprecating ShardedTensor.
  local_shape = tensor.shape
/opt/conda/lib/python3.11/site-packages/torch/distributed/fsdp/_state_dict_utils.py:744: FutureWarning: Please use DTensor instead and we are deprecating ShardedTensor.
  tensor.shape,
/opt/conda/lib/python3.11/site-packages/torch/distributed/fsdp/_state_dict_utils.py:746: FutureWarning: Please use DTensor instead and we are deprecating ShardedTensor.
  tensor.dtype,
/opt/conda/lib/python3.11/site-packages/torch/distributed/fsdp/_state_dict_utils.py:747: FutureWarning: Please use DTensor instead and we are deprecating ShardedTensor.
  tensor.device,
/workspace/llama-recipes/src/llama_recipes/model_checkpointing/checkpoint_handler.py:112: FutureWarning: `save_state_dict` is deprecated and will be removed in future versions.Please use `save` instead.
  dist_cp.save_state_dict(
/workspace/llama-recipes/src/llama_recipes/model_checkpointing/checkpoint_handler.py:112: FutureWarning: `save_state_dict` is deprecated and will be removed in future versions.Please use `save` instead.
  dist_cp.save_state_dict(
fsdp-worker-1:73:384 [0] NCCL INFO Channel 00/1 : 3[1] -> 0[0] [receive] via NET/Socket/0/Shared
fsdp-worker-1:73:384 [0] NCCL INFO Channel 01/1 : 3[1] -> 0[0] [receive] via NET/Socket/0/Shared
fsdp-worker-1:74:385 [1] NCCL INFO Channel 00 : 1[1] -> 0[0] via SHM/direct/direct
fsdp-worker-1:74:385 [1] NCCL INFO Channel 01 : 1[1] -> 0[0] via SHM/direct/direct
fsdp-worker-1:73:384 [0] NCCL INFO Channel 00/1 : 2[0] -> 0[0] [receive] via NET/Socket/0/Shared
fsdp-worker-1:73:384 [0] NCCL INFO Channel 01/1 : 2[0] -> 0[0] [receive] via NET/Socket/0/Shared
fsdp-worker-1:73:387 [0] NCCL INFO Channel 00 : 0[0] -> 1[1] via SHM/direct/direct
fsdp-worker-1:73:387 [0] NCCL INFO Channel 01 : 0[0] -> 1[1] via SHM/direct/direct
fsdp-worker-1:73:387 [0] NCCL INFO Channel 00/1 : 0[0] -> 2[0] [send] via NET/Socket/0/Shared
fsdp-worker-1:73:387 [0] NCCL INFO Channel 01/1 : 0[0] -> 2[0] [send] via NET/Socket/0/Shared
fsdp-worker-1:73:387 [0] NCCL INFO Channel 00/1 : 0[0] -> 3[1] [send] via NET/Socket/0/Shared
fsdp-worker-1:73:387 [0] NCCL INFO Channel 01/1 : 0[0] -> 3[1] [send] via NET/Socket/0/Shared
Sharded state checkpoint saved to /workspace/llama-recipes/PATH/to/save/FSDP/model/fine-tuned-meta-llama/Llama-2-7b-hf
Checkpoint Time = 24.8918

best eval loss on epoch 1 is 1.0449419021606445
Epoch 1: train_perplexity=4.3019, train_epoch_loss=1.4591, epoch time 804.0793660259951s
```
Log snips
```
[prd@csctmp-r760-18 fsdp-test]$ kubectl logs fsdp-worker-0 | grep epoch
 eval_ppl=tensor(2.8432, device='cuda:0') eval_epoch_loss=tensor(1.0449, device='cuda:0')
 eval_ppl=tensor(3.2116, device='cuda:0') eval_epoch_loss=tensor(1.1668, device='cuda:0')

[prd@csctmp-r760-18 fsdp-test]$ kubectl logs fsdp-worker-1 | grep epoch
 eval_ppl=tensor(2.8432, device='cuda:0') eval_epoch_loss=tensor(1.0449, device='cuda:0')
best eval loss on epoch 1 is 1.0449419021606445
Epoch 1: train_perplexity=4.3019, train_epoch_loss=1.4591, epoch time 804.0793660259951s
 eval_ppl=tensor(3.2116, device='cuda:0') eval_epoch_loss=tensor(1.1668, device='cuda:0')
Epoch 2: train_perplexity=2.1021, train_epoch_loss=0.7429, epoch time 799.0331504560017s
```
After a job is complete, it needs to be deleted before initiating a new run. We’ve also observed that deleting the etcd pod and letting it restart prior to launching a new job helps avoid a RendezvousClosedError. Else we can change the rdzvId: '1' in the YAML to a different number.

### Installing and configuring kubectl on windows
```
https://site-ghwmnxe1v6.talkyard.net/-12/faq-how-to-set-up-kubeconfig-on-windows-wise-paasensaas-k8s-service
```
### References
- https://www.kubeflow.org/docs/components/training/user-guides/tensorflow/
- https://iamondemand.com/blog/scaling-keras-on-kubernetes-with-kubeflow/#:~:text=Keras%20models%20deployed%20using%20Seldon,RAM%20load%20or%20network%20requests.
- https://kueue.sigs.k8s.io/docs/tasks/run/kubeflow/pytorchjobs/
- datascience-registry.cn-beijing.cr.aliyuncs.com/kubeflow-examples/multi_worker_strategy:0.1.1
- https://aws.amazon.com/blogs/machine-learning/scale-llms-with-pytorch-2-0-fsdp-on-amazon-eks-part-2/
