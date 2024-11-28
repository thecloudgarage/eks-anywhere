Create the EKS Anywhere on Bare Metal Cluster
```
eksctl anywhere create cluster --hardware-csv hardware.csv -f clusterconfig.yaml -v 4

2024-11-27T21:39:57.501-0600    V0      Warning: The recommended number of control plane nodes is 3 or 5
2024-11-27T21:39:57.592-0600    V4      Reading release manifest        {"url": "https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml"}
2024-11-27T21:39:57.773-0600    V4      Reading bundles manifest        {"url": "https://anywhere-assets.eks.amazonaws.com/releases/bundles/78/manifest.yaml"}
2024-11-27T21:39:57.860-0600    V4      Using CAPI provider versions    {"Core Cluster API": "v1.7.2+c70e887", "Kubeadm Bootstrap": "v1.7.2+567da7c", "Kubeadm Control Plane": "v1.7.2+8a712d7", "External etcd Bootstrap": "v1.0.13+4c4fcd8", "External etcd Controller": "v1.0.23+ec8dc7a", "Cluster API Provider Tinkerbell": "v0.5.3+b436901"}
2024-11-27T21:39:58.022-0600    V4      Reading release manifest        {"url": "https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml"}
2024-11-27T21:39:58.074-0600    V0      Warning: The recommended number of control plane nodes is 3 or 5
2024-11-27T21:39:58.074-0600    V2      Pulling docker image    {"image": "public.ecr.aws/eks-anywhere/cli-tools:v0.20.7-eks-a-78"}
2024-11-27T21:40:08.779-0600    V3      Initializing long running container     {"name": "eksa_1732765198074651940", "image": "public.ecr.aws/eks-anywhere/cli-tools:v0.20.7-eks-a-78"}
2024-11-27T21:40:09.911-0600    V4      Inferring local Tinkerbell Bootstrap IP from environment
2024-11-27T21:40:09.911-0600    V4      Tinkerbell IP   {"tinkerbell-ip": "172.29.198.72"}
2024-11-27T21:40:09.911-0600    V0      Using the new workflow using the controller for management cluster create
2024-11-27T21:40:09.911-0600    V4      Task start      {"task_name": "setup-validate"}
2024-11-27T21:40:09.911-0600    V0      Performing setup and validations
2024-11-27T21:40:10.933-0600    V0      ✅ Tinkerbell Provider setup is valid
2024-11-27T21:40:10.933-0600    V0      ✅ Validate OS is compatible with registry mirror configuration
2024-11-27T21:40:10.933-0600    V0      ✅ Validate certificate for registry mirror
2024-11-27T21:40:10.933-0600    V0      ✅ Validate authentication for git provider
2024-11-27T21:40:10.933-0600    V0      ✅ Validate cluster's eksaVersion matches EKS-A version
2024-11-27T21:40:10.933-0600    V4      Task finished   {"task_name": "setup-validate", "duration": "1.021874284s"}
2024-11-27T21:40:10.933-0600    V4      ----------------------------------
2024-11-27T21:40:10.933-0600    V4      Task start      {"task_name": "bootstrap-cluster-init"}
2024-11-27T21:40:10.933-0600    V0      Creating new bootstrap cluster
2024-11-27T21:40:10.934-0600    V4      Creating kind cluster   {"name": "poc5-eks-a-cluster", "kubeconfig": "poc5/generated/poc5.kind.kubeconfig"}
2024-11-27T21:41:08.891-0600    V4      Task finished   {"task_name": "bootstrap-cluster-init", "duration": "57.957120405s"}
2024-11-27T21:41:08.891-0600    V4      ----------------------------------
2024-11-27T21:41:08.891-0600    V4      Task start      {"task_name": "update-secrets-create"}
2024-11-27T21:41:08.891-0600    V4      Task finished   {"task_name": "update-secrets-create", "duration": "1.698µs"}
2024-11-27T21:41:08.891-0600    V4      ----------------------------------
2024-11-27T21:41:08.891-0600    V4      Task start      {"task_name": "install-capi-components-bootstrap"}
2024-11-27T21:41:08.891-0600    V0      Provider specific pre-capi-install-setup on bootstrap cluster
2024-11-27T21:41:08.891-0600    V4      Installing Tinkerbell stack on bootstrap cluster
2024-11-27T21:41:08.891-0600    V4      Adding annotation for tinkerbell ip on bootstrap cluster
2024-11-27T21:41:45.820-0600    V0      Installing cluster-api providers on bootstrap cluster
2024-11-27T21:42:22.486-0600    V0      Provider specific post-setup
2024-11-27T21:42:28.966-0600    V4      Task finished   {"task_name": "install-capi-components-bootstrap", "duration": "1m20.07540658s"}
2024-11-27T21:42:28.966-0600    V4      ----------------------------------
2024-11-27T21:42:28.966-0600    V4      Task start      {"task_name": "eksa-components-bootstrap-install"}
2024-11-27T21:42:28.966-0600    V0      Installing EKS-A custom components on bootstrap cluster
2024-11-27T21:42:28.966-0600    V0      Installing EKS-D components
2024-11-27T21:42:29.729-0600    V0      Installing EKS-A custom components (CRD and controller)
2024-11-27T21:43:19.780-0600    V1      Applying Bundles to cluster
2024-11-27T21:43:22.047-0600    V1      Applying EKSA Release to cluster
2024-11-27T21:43:22.597-0600    V4      Applying eksd manifest to cluster
2024-11-27T21:43:23.109-0600    V4      Applying eksd manifest to cluster
2024-11-27T21:43:23.734-0600    V4      Applying eksd manifest to cluster
2024-11-27T21:43:24.365-0600    V4      Applying eksd manifest to cluster
2024-11-27T21:43:24.773-0600    V4      Applying eksd manifest to cluster
2024-11-27T21:43:25.174-0600    V4      Task finished   {"task_name": "eksa-components-bootstrap-install", "duration": "56.207717199s"}
2024-11-27T21:43:25.174-0600    V4      ----------------------------------
2024-11-27T21:43:25.174-0600    V4      Task start      {"task_name": "workload-cluster-init"}
2024-11-27T21:43:25.174-0600    V0      Creating new workload cluster
2024-11-27T21:43:25.174-0600    V3      Applying cluster spec
2024-11-27T21:43:50.277-0600    V3      Waiting for control plane to be ready
2024-11-27T22:03:05.865-0600    V3      Waiting for default CNI to be updated
2024-11-27T22:03:28.209-0600    V3      Waiting for worker nodes to be ready
2024-11-27T22:21:36.787-0600    V3      Waiting for cluster changes to be completed
2024-11-27T22:21:59.400-0600    V0      Creating EKS-A namespace
2024-11-27T22:21:59.754-0600    V0      Installing cluster-api providers on workload cluster
2024-11-27T22:22:32.329-0600    V0      Installing EKS-A secrets on workload cluster
2024-11-27T22:22:33.237-0600    V4      Task finished   {"task_name": "workload-cluster-init", "duration": "39m8.063153561s"}
2024-11-27T22:22:33.237-0600    V4      ----------------------------------
2024-11-27T22:22:33.237-0600    V4      Task start      {"task_name": "install-resources-on-management-cluster"}
2024-11-27T22:22:33.237-0600    V4      Installing Tinkerbell stack on workload cluster
2024-11-27T22:23:01.044-0600    V4      Removing local boots container
2024-11-27T22:23:01.140-0600    V4      Task finished   {"task_name": "install-resources-on-management-cluster", "duration": "27.903015056s"}
2024-11-27T22:23:01.140-0600    V4      ----------------------------------
2024-11-27T22:23:01.140-0600    V4      Task start      {"task_name": "capi-management-move"}
2024-11-27T22:23:02.380-0600    V0      Moving cluster management from bootstrap to workload cluster
2024-11-27T22:23:02.380-0600    V3      Waiting for management machines to be ready before move
2024-11-27T22:23:02.971-0600    V4      Nodes ready     {"total": 3}
2024-11-27T22:23:02.972-0600    V3      Waiting for management cluster to be ready before move
2024-11-27T22:23:06.160-0600    V3      Waiting for workload cluster control plane to be ready after move
2024-11-27T22:23:07.127-0600    V3      Waiting for workload cluster control plane replicas to be ready after move
2024-11-27T22:23:07.314-0600    V3      Waiting for workload cluster machine deployment replicas to be ready after move
2024-11-27T22:23:07.500-0600    V3      Waiting for machines to be ready after move
2024-11-27T22:23:08.051-0600    V4      Nodes ready     {"total": 3}
2024-11-27T22:23:08.051-0600    V4      Task finished   {"task_name": "capi-management-move", "duration": "6.910853945s"}
2024-11-27T22:23:08.051-0600    V4      ----------------------------------
2024-11-27T22:23:08.051-0600    V4      Task start      {"task_name": "eksa-components-workload-install"}
2024-11-27T22:23:08.051-0600    V0      Removing Tinkerbell IP annotation
2024-11-27T22:23:08.051-0600    V0      Installing EKS-A custom components on workload cluster
2024-11-27T22:23:08.051-0600    V0      Installing EKS-D components
2024-11-27T22:23:09.434-0600    V0      Installing EKS-A custom components (CRD and controller)
2024-11-27T22:23:57.512-0600    V1      Applying Bundles to cluster
2024-11-27T22:23:58.545-0600    V1      Applying EKSA Release to cluster
2024-11-27T22:23:59.069-0600    V4      Applying eksd manifest to cluster
2024-11-27T22:23:59.537-0600    V4      Applying eksd manifest to cluster
2024-11-27T22:24:00.028-0600    V4      Applying eksd manifest to cluster
2024-11-27T22:24:00.558-0600    V4      Applying eksd manifest to cluster
2024-11-27T22:24:01.112-0600    V4      Applying eksd manifest to cluster
2024-11-27T22:24:01.509-0600    V0      Moving cluster spec to workload cluster
2024-11-27T22:24:01.509-0600    V3      Moving the cluster object
2024-11-27T22:24:05.243-0600    V4      Task finished   {"task_name": "eksa-components-workload-install", "duration": "57.191825869s"}
2024-11-27T22:24:05.243-0600    V4      ----------------------------------
2024-11-27T22:24:05.243-0600    V4      Task start      {"task_name": "gitops-manager-install"}
2024-11-27T22:24:05.243-0600    V0      Installing GitOps Toolkit on workload cluster
2024-11-27T22:24:05.243-0600    V0      GitOps field not specified, bootstrap flux skipped
2024-11-27T22:24:05.243-0600    V4      Task finished   {"task_name": "gitops-manager-install", "duration": "51.754µs"}
2024-11-27T22:24:05.243-0600    V4      ----------------------------------
2024-11-27T22:24:05.243-0600    V4      Task start      {"task_name": "write-cluster-config"}
2024-11-27T22:24:05.243-0600    V0      Writing cluster config file
2024-11-27T22:24:05.246-0600    V4      Task finished   {"task_name": "write-cluster-config", "duration": "2.536174ms"}
2024-11-27T22:24:05.246-0600    V4      ----------------------------------
2024-11-27T22:24:05.246-0600    V4      Task start      {"task_name": "delete-kind-cluster"}
2024-11-27T22:24:05.246-0600    V0      Deleting bootstrap cluster
2024-11-27T22:24:05.755-0600    V4      Deleting kind cluster   {"name": "poc5-eks-a-cluster"}
2024-11-27T22:24:07.099-0600    V0      🎉 Cluster created!
2024-11-27T22:24:07.099-0600    V4      Task finished   {"task_name": "delete-kind-cluster", "duration": "1.853570045s"}
2024-11-27T22:24:07.099-0600    V4      ----------------------------------
2024-11-27T22:24:07.100-0600    V4      Task start      {"task_name": "install-curated-packages"}
--------------------------------------------------------------------------------------
The Amazon EKS Anywhere Curated Packages are only available to customers with the
Amazon EKS Anywhere Enterprise Subscription
--------------------------------------------------------------------------------------
2024-11-27T22:24:07.100-0600    V0      Enabling curated packages on the cluster
2024-11-27T22:24:07.101-0600    V0      Installing helm chart on cluster        {"chart": "eks-anywhere-packages", "version": "0.4.4-eks-a-78"}
2024-11-27T22:24:41.993-0600    V4      Task finished   {"task_name": "install-curated-packages", "duration": "34.893846344s"}
2024-11-27T22:24:41.993-0600    V4      ----------------------------------
2024-11-27T22:24:41.993-0600    V4      Tasks completed {"duration": "44m32.082008881s"}
2024-11-27T22:24:41.995-0600    V3      Cleaning up long running container      {"name": "eksa_1732765198074651940"}
[prd@csctmp-rh9-prd ~]$
```
Export Kubeconfig
```
export KUBECONFIG=/home/prd/poc5/poc5-eks-a-cluster.kubeconfig
```
Get Node Information
```
kubectl get nodes -o wide
NAME      STATUS   ROLES           AGE   VERSION               INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
prdc-01   Ready    control-plane   54m   v1.30.4-eks-16b398d   172.29.198.60   <none>        Ubuntu 22.04.5 LTS   5.15.0-124-generic   containerd://1.7.22-0-g7f7fdf5fe
prdw-02   Ready    <none>          36m   v1.30.4-eks-16b398d   172.29.198.67   <none>        Ubuntu 22.04.5 LTS   5.15.0-124-generic   containerd://1.7.22-0-g7f7fdf5fe
prdw-03   Ready    <none>          35m   v1.30.4-eks-16b398d   172.29.198.68   <none>        Ubuntu 22.04.5 LTS   5.15.0-124-generic   containerd://1.7.22-0-g7f7fdf5fe
```
Label the GPU nodes on EKS Anywhere Bare-metal
```
kubectl label node prdw-02 gputype=l40s
kubectl label node prdw-03 gputype=l40s
```
Install NVIDIA GPU Operator
```
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator
kubectl get pods -n gpu-operator
kubectl get node -o json | jq '.items[].metadata.labels'
```
If already installed, then use the upgrade
```
helm upgrade --install --wait $(helm list -n gpu-operator | grep gpu-operator | awk '{print $1}') -n gpu-operator nvidia/gpu-operator
```
Validate a sample application using L40S GPUs
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nvidia-smi
  namespace: gpu-operator
spec:
  nodeSelector:
    gputype: "l40s"
  restartPolicy: OnFailure
  containers:
    - name: nvidia-smi
      image: nvidia/cuda:12.3.1-devel-ubuntu22.04
      args:
        - "nvidia-smi"
      resources:
        limits:
          nvidia.com/gpu: 2 #change count based on number of GPU slots
EOF
```
Note: The Image download and container creation takes some time. Observe the nvidia-sim application
```
kubectl get pods -n gpu-operator
kubectl logs nvidia-smi -n gpu-operator
```
Sample output
```
kubectl logs nvidia-smi -n gpu-operator

==========
== CUDA ==
==========

CUDA Version 12.3.1

Container image Copyright (c) 2016-2023, NVIDIA CORPORATION & AFFILIATES. All rights reserved.

This container image and its contents are governed by the NVIDIA Deep Learning Container License.
By pulling and using the container, you accept the terms and conditions of this license:
https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license

A copy of this license is made available in this container at /NGC-DL-CONTAINER-LICENSE for your convenience.

Thu Nov 28 05:49:55 2024
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.127.05             Driver Version: 550.127.05     CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA L40S                    On  |   00000000:0D:00.0 Off |                    0 |
| N/A   32C    P8             36W /  350W |       1MiB /  46068MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA L40S                    On  |   00000000:B5:00.0 Off |                    0 |
| N/A   32C    P8             35W /  350W |       1MiB /  46068MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```
Install METALLB Load Balancer
```
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb --wait --timeout 15m --namespace metallb-system --create-namespace
```
If already installed
```
helm upgrade --install metallb metallb/metallb --wait --timeout 15m --namespace metallb-system
```

Validate the metallb pods
```
kubectl get pods -n metallb-system
NAME                                  READY   STATUS    RESTARTS   AGE
metallb-controller-77cb7f5d88-t4wr7   1/1     Running   0          53s
metallb-speaker-6xk5g                 4/4     Running   0          53s
metallb-speaker-flsjj                 4/4     Running   0          53s
metallb-speaker-r7f8h                 4/4     Running   0          53s
```
Create L2 Advertisements for MetalLB
```
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.29.198.75-172.29.198.75
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF
```
Install kserve for model serving

![image](https://github.com/user-attachments/assets/238b55bc-16ec-4aab-9bb7-77198adfb45a)
![image](https://github.com/user-attachments/assets/e788b275-3969-4db5-8057-7a53574a5b9a)


```
curl -s "https://raw.githubusercontent.com/kserve/kserve/release-0.13/hack/quick_install.sh" | bash
```
A quick glimpse of all relevant pods
```
for namespace in kserve knative-serving istio-system metallb-system gpu-operator; do
kubectl get pods -n $namespace -o wide
done
```
Example output
```
for namespace in kserve knative-serving istio-system metallb-system gpu-operator; do kubectl get pods -n $namespace; done
NAME                                         READY   STATUS    RESTARTS   AGE
kserve-controller-manager-768d8f5457-57vp4   2/2     Running   0          46m
NAME                                    READY   STATUS    RESTARTS   AGE
activator-56cffc7754-5xvdb              1/1     Running   0          48m
autoscaler-858cbd4dd6-7blf6             1/1     Running   0          48m
controller-686ff8bbc8-jd7mt             1/1     Running   0          48m
net-istio-controller-5df666b44c-qmlq8   1/1     Running   0          48m
net-istio-webhook-ff6665657-kqv9m       1/1     Running   0          48m
webhook-6fdc5964f6-2cwbd                1/1     Running   0          48m
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingressgateway-7db5d74887-7cm48   1/1     Running   0          48m
istiod-77dc68476c-gw4rw                 1/1     Running   0          48m
NAME                                  READY   STATUS    RESTARTS   AGE
metallb-controller-77cb7f5d88-t4wr7   1/1     Running   0          24m
metallb-speaker-6xk5g                 4/4     Running   0          24m
metallb-speaker-flsjj                 4/4     Running   0          24m
metallb-speaker-r7f8h                 4/4     Running   0          24m
NAME                                                              READY   STATUS      RESTARTS   AGE
gpu-feature-discovery-44wlm                                       1/1     Running     0          69m
gpu-feature-discovery-4j6lw                                       1/1     Running     0          69m
gpu-operator-1732769849-node-feature-discovery-gc-57dccb75trz5d   1/1     Running     0          70m
gpu-operator-1732769849-node-feature-discovery-master-5fd9k7lfz   1/1     Running     0          70m
gpu-operator-1732769849-node-feature-discovery-worker-422mx       1/1     Running     0          70m
gpu-operator-1732769849-node-feature-discovery-worker-mqkh5       1/1     Running     0          70m
gpu-operator-1732769849-node-feature-discovery-worker-s2jl6       1/1     Running     0          70m
gpu-operator-755556f9f8-pgbzz                                     1/1     Running     0          70m
nvidia-container-toolkit-daemonset-lkcgj                          1/1     Running     0          69m
nvidia-container-toolkit-daemonset-rp8w7                          1/1     Running     0          69m
nvidia-cuda-validator-ncmqg                                       0/1     Completed   0          67m
nvidia-cuda-validator-w2jrv                                       0/1     Completed   0          66m
nvidia-dcgm-exporter-njftc                                        1/1     Running     0          69m
nvidia-dcgm-exporter-wrb65                                        1/1     Running     0          69m
nvidia-device-plugin-daemonset-8ww7n                              1/1     Running     0          69m
nvidia-device-plugin-daemonset-tkrkn                              1/1     Running     0          69m
nvidia-driver-daemonset-9r6jj                                     1/1     Running     0          70m
nvidia-driver-daemonset-mfz9n                                     1/1     Running     0          70m
nvidia-operator-validator-pcdzq                                   1/1     Running     0          69m
nvidia-operator-validator-r9trz                                   1/1     Running     0          69m
nvidia-smi                                                        0/1     Completed   0          20m
```
Validate Istio Ingress Gateway
```
kubectl get svc istio-ingressgateway -n istio-system
```
### Deploying Hugging Face LLAMA 3.1 8B LLM model using vLLM backend
- Ensure that you have an access token setup in HuggingFace by viewing the license agreement and clicking on model card
- You have applied for the model access for Llama3 in Huggingface and it shows as accepted in your profile settings > gated repos status
```
kubectl apply -f - <<EOF
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: huggingface-llama3
spec:
  predictor:
    model:
      modelFormat:
        name: huggingface
      args:
        - --model_name=llama3
        - --model_id=meta-llama/meta-llama-3-8b-instruct
      env:
        - name: HF_TOKEN
          value: "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"
      resources:
        limits:
          cpu: "6"
          memory: 24Gi
          nvidia.com/gpu: "1"
        requests:
          cpu: "6"
          memory: 24Gi
          nvidia.com/gpu: "1"
EOF

```
Verify the Inference Service
```
kubectl get inferenceservices huggingface-llama3
kubectl get pods
```
Determine the ingress IP and ports
```
export MODEL_NAME=llama3
export SERVICE_HOSTNAME=$(kubectl get inferenceservice huggingface-llama3 -o jsonpath='{.status.url}' | cut -d "/" -f 3)
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
```
Validate the inference service
```
curl -v http://${INGRESS_HOST}:${INGRESS_PORT}/openai/v1/completions \
-H "content-type: application/json" -H "Host: ${SERVICE_HOSTNAME}" \
-d '{"model": "llama3", "prompt": "Write a poem about colors", "stream":false, "max_tokens": 30}'
```
### Deploying HuggingFace Bloom7b1 model
```
kubectl apply -f - <<EOF
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: bigscience-bloom-7b1
spec:
  predictor:
    model:
      modelFormat:
        name: huggingface
      args:
        - --model_name=bloom-7b1
        - --model_id=bigscience/bloom-7b1
      env:
        - name: HF_TOKEN
          value: "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"
      resources:
        limits:
          cpu: "6"
          memory: 32Gi
          nvidia.com/gpu: "1"
        requests:
          cpu: "6"
          memory: 32Gi
          nvidia.com/gpu: "1"
EOF
```
Validate
```
curl -v \
  -H "Host: ${SERVICE_HOSTNAME}" \
  -H "Content-Type: application/json" \
  -d '{
		"model": "bloom-7b1",
		"prompt": "Once upon a time,",
		"max_tokens": 512,
		"temperature": 0.5
	}' http://${INGRESS_HOST}:${INGRESS_PORT}/openai/v1/completions
```
### Deploying Transformer (Pre/Post processing) and BERT for predictions
```
kubectl patch cm config-deployment --patch '{"data":{"registriesSkippingTagResolving":"nvcr.io"}}' -n knative-serving
kubectl patch cm config-deployment --patch '{"data":{"progressDeadline": "600s"}}' -n knative-serving

cat <<EOF | kubectl apply -f -
apiVersion: "serving.kserve.io/v1beta1"
kind: "InferenceService"
metadata:
  name: "bert-v2"
spec:
  transformer:
    containers:
      - name: kserve-container      
        image: kfserving/bert-transformer-v2:latest
        command:
          - "python"
          - "-m"
          - "bert_transformer_v2"
        env:
          - name: STORAGE_URI
            value: "gs://kfserving-examples/models/triton/bert-transformer"
  predictor:
    triton:
      runtimeVersion: 20.10-py3
      resources:
        limits:
          cpu: "1"
          memory: 8Gi
          nvidia.com/gpu: "1"
        requests:
          cpu: "1"
          memory: 8Gi
          nvidia.com/gpu: "1"
      storageUri: "gs://kfserving-examples/models/triton/bert"
EOF

cat <<EOF > input-bert.json
{
  "instances": [
    "What President is credited with the original notion of putting Americans in space?"
  ]
}
EOF
```
Validate
```
MODEL_NAME=bert-v2
INPUT_PATH=@./input-bert.json
SERVICE_HOSTNAME=$(kubectl get inferenceservices bert-v2 -o jsonpath='{.status.url}' | cut -d "/" -f 3)
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

curl -v -H "Host: ${SERVICE_HOSTNAME}" -H "Content-Type: application/json" -d $INPUT_PATH http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/$MODEL_NAME:predict
```
