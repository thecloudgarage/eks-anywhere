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
          nvidia.com/gpu: 1
EOF
```
Observe the nvidia-sim application
```
kubectl get pods -n gpu-operator
kubectl logs <pod-name> -n gpu-operator
```
Install METALLB Load Balancer
```
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb --wait --timeout 15m --namespace metallb-system --create-namespace
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
curl -s "https://raw.githubusercontent.com/kserve/kserve/release-0.11/hack/quick_install.sh" | bash
```
Validate Istio Ingress Gateway
```
kubectl get svc istio-ingressgateway -n istio-system
```
Deploy a LLM based on bloom7b1
```
kubectl create namespace kserve-test

cat <<EOF | kubectl apply -f -
apiVersion: "serving.kserve.io/v1beta1"
kind: "InferenceService"
metadata:
  labels:
    controller-tools.k8s.io: "1.0"
  name: "kserve-custom-model"
spec:
  predictor:
    containers:
    - image: vinayaks117/kserve-model-repo:v1.0
      resources:
        limits:
          cpu: "2"
          memory: 32Gi
          nvidia.com/gpu: "2"
        requests:
          cpu: "2"
          memory: 32Gi
          nvidia.com/gpu: "2"
EOF
```
Run a sample test for the LLM service
```
kubectl get inferenceservice -A 
kubectl port-forward -n istio-system service/istio-ingressgateway 8081:80

cat <<EOF > input.json
{"sequence": "Hello, my cats are cute."}
EOF

curl -v -H "Host: kserve-custom-model.default.example.com" http://localhost:8081/v1/models/bert-sentiment:predict  -d @./input.json
```
