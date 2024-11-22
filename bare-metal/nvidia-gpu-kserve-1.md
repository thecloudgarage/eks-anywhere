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
curl -s "https://raw.githubusercontent.com/kserve/kserve/release-0.13/hack/quick_install.sh" | bash
```
Validate Istio Ingress Gateway
```
kubectl get svc istio-ingressgateway -n istio-system
```
Let's Serve the Hugging Face LLM model using vLLM backend
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

