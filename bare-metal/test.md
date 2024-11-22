Deploy a custom model based on HuggingFace BERT with KServe
```
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
