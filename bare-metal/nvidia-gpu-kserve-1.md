```
kubectl label node prdw-02 gputype=l40s
kubectl label node prdw-03 gputype=l40s

helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update

helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator

kubectl get pods -n gpu-operator

kubectl get node -o json | jq '.items[].metadata.labels'

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

kubectl get pods -n gpu-operator

kubectl logs <pod-name> -n gpu-operator

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
  - 172.24.165.21-172.24.165.25
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF

curl -s "https://raw.githubusercontent.com/kserve/kserve/release-0.11/hack/quick_install.sh" | bash

kubectl get svc istio-ingressgateway -n istio-system

kubectl create namespace kserve-test

cat <<EOF | kubectl apply -f 
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: "bloom7b1"
spec:
  predictor:
    pytorch:
      runtimeVersion: 0.8.2
      storageUri: gs://kfserving-examples/models/torchserve/llm/Huggingface_accelerate/bloom
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






SERVICE_HOSTNAME=$(kubectl get inferenceservice bloom7b1 -o jsonpath='{.status.url}' | cut -d "/" -f 3)

curl -v \
  -H "Host: ${SERVICE_HOSTNAME}" \
  -H "Content-Type: application/json" \
  -d @./text.json \
  http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/bloom7b1:predict

{"predictions":["My dog is cute.\nNice.\n- Hey, Mom.\n- Yeah?\nWhat color's your dog?\n- It's gray.\n- Gray?\nYeah.\nIt looks gray to me.\n- Where'd you get it?\n- Well, Dad says it's kind of...\n- Gray?\n- Gray.\nYou got a gray dog?\n- It's gray.\n- Gray.\nIs your dog gray?\nAre you sure?\nNo.\nYou sure"]}
