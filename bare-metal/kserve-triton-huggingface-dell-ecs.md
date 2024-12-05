# The Prowess of Dell ECS Object Storage

![image](https://github.com/user-attachments/assets/154bf994-6050-41d2-947d-eb681c33ad61)

Nvidia Triton Inference Server is a robust serving runtime thanks to its optmized performance, scalability, and flexibility. Combined with the expansive library of Hugging Face, which offers state-of-the-art natural language processing capabilities, it opens up immense possibilities for deploying production-ready Huggface Face transformer based models.

By harnessing the power of these tools, here we'll show you how KServe can help further simplify the Triton Inference containers deployment and make efficient use of GPUs by automatically wiring up the open inference protocol between pre/post processing(tokenization) and model inference on triton inference container.

### Install NVIDIA GPU operator 
```
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator
```
### Install and configure Metallb Load balancer
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

### Install Kserve
```
curl -s "https://raw.githubusercontent.com/kserve/kserve/release-0.13/hack/quick_install.sh" | bash
```
### Verify Ingress gateway External IP
```
kubectl get svc istio-ingressgateway -n istio-system
```
### Skip tag resolution for nvcr.io which requires auth to resolve triton inference server image digest
```
kubectl patch cm config-deployment --patch '{"data":{"registriesSkippingTagResolving":"nvcr.io"}}' -n knative-serving
```
### Install AWS CLI and gsutil CLI. Also ensure that AWS CLI is configured with Dell ECS S3 IAM keys
```
# Install AWS CLI based on OS distribution
# For gsutil follow the below steps
cd $HOME
wget https://storage.googleapis.com/pub/gsutil.tar.gz
tar xfz gsutil.tar.gz -C $HOME
export PATH=${PATH}:$HOME/gsutil
```
### Store the Triton HuggingFace BERT example model in Dell ECS storage
```
# List the content of the Kserve example GCS storage bucket
gsutil ls gs://kfserving-examples/models/triton/huggingface/model_repository

# Sample output
gs://kfserving-examples/models/triton/huggingface/model_repository/.DS_Store
gs://kfserving-examples/models/triton/huggingface/model_repository/bert/
gs://kfserving-examples/models/triton/huggingface/model_repository/roberta/

# Create a bucket in Dell ECS S3 storage
aws --endpoint-url https://object.ecstestdrive.com s3 mb s3://triton-huggingface
make_bucket: triton-huggingface

# Create a local directory to download the model
mkdir -p $HOME/triton-huggingface
cd $HOME/triton-huggingface

# Download the model using gsutil CLI
gsutil cp -r gs://kfserving-examples/models/triton/huggingface/model_repository .

# Sample output
Copying gs://kfserving-examples/models/triton/huggingface/model_repository/.DS_Store...
Copying gs://kfserving-examples/models/triton/huggingface/model_repository/bert/1/model.pt...
==> NOTE: You are downloading one or more large file(s), which would
run significantly faster if you enabled sliced object downloads. This
feature is enabled by default but requires that compiled crcmod be
installed (see "gsutil help crcmod").

Copying gs://kfserving-examples/models/triton/huggingface/model_repository/bert/config.pbtxt...
Copying gs://kfserving-examples/models/triton/huggingface/model_repository/roberta/.DS_Store...
| [4 files][507.6 MiB/507.6 MiB]   19.1 MiB/s
==> NOTE: You are performing a sequence of gsutil operations that may
run significantly faster if you instead use gsutil -m cp ... Please
see the -m section under "gsutil help options" for further information
about when gsutil -m can be advantageous.

Copying gs://kfserving-examples/models/triton/huggingface/model_repository/roberta/1/model.pt...
Copying gs://kfserving-examples/models/triton/huggingface/model_repository/roberta/config.pbtxt...
- [6 files][  1.8 GiB/  1.8 GiB]   20.8 MiB/s
Operation completed over 6 objects/1.8 GiB.

# Upload the locally copied model to Dell ECS S3 storage bucket created ealier
aws --endpoint-url https://object.ecstestdrive.com s3 cp model_repository s3://triton-huggingface/ --recursive

# Sample output
upload: model_repository/.DS_Store to s3://triton-huggingface/.DS_Store
upload: model_repository/bert/config.pbtxt to s3://triton-huggingface/bert/config.pbtxt
upload: model_repository/roberta/config.pbtxt to s3://triton-huggingface/roberta/config.pbtxt
upload: model_repository/roberta/.DS_Store to s3://triton-huggingface/roberta/.DS_Store
upload: model_repository/bert/1/model.pt to s3://triton-huggingface/bert/1/model.pt
upload: model_repository/roberta/1/model.pt to s3://triton-huggingface/roberta/1/model.pt
```
### Create the secret and service account in the EKS Anywhere bare metal cluster to be used by Kserve Inferencing service
```
# Export your Dell ECS S3 Keys

export ECS_ACCESS_KEY_ID=XXXXXXXXXXXX
export ECS_SECRET_ACCESS_KEY=XXXXXXXXXXXX

# Create secret

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ecs-creds
  annotations:
     serving.kserve.io/s3-endpoint: object.ecstestdrive.com # replace with your s3 endpoint 
     serving.kserve.io/s3-usehttps: "1" # by default 1, if testing with http
     serving.kserve.io/s3-region: "us-east-1"
     serving.kserve.io/s3-useanoncredential: "false" # omitting this is the same as false, if true will ignore provided credential and use anonymous credentials
type: Opaque
stringData: 
  AWS_ACCESS_KEY_ID: $ECS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY: $ECS_SECRET_ACCESS_KEY
EOF

# Create Service account

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ecs-sa
secrets:
- name: ecs-creds
EOF
```
### Deploy the Kserve Inference service
```
cat <<EOF | kubectl apply -f -
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: huggingface-triton
spec:
  predictor:
    serviceAccountName: ecs-sa #specify the name of the service account created that utilizes the Dell ECS S3 credentials
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
      storageUri: s3://triton-huggingface # Specify the bucket under which the model files were copied in Dell ECS storage
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
### Validate the Inference Service
```
MODEL_NAME=bert
SERVICE_HOSTNAME=$(kubectl get inferenceservice huggingface-triton -o jsonpath='{.status.url}' | cut -d "/" -f 3)
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

curl -H "content-type:application/json" -H "Host: ${SERVICE_HOSTNAME}" -v http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/${MODEL_NAME}:predict -d '{"instances": ["The capital of france is [MASK]."] }' | jq .
```
### Output
```
*   Trying 172.29.198.75:80...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0* Connected to 172.29.198.75 (172.29.198.75) port 80 (#0)
> POST /v1/models/bert:predict HTTP/1.1
> Host: huggingface-triton.default.example.com
> User-Agent: curl/7.76.1
> Accept: */*
> content-type:application/json
> Content-Length: 52
>
} [52 bytes data]
100    52    0     0  100    52      0      9  0:00:05  0:00:05 --:--:--     9* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< content-length: 25
< content-type: application/json
< date: Wed, 04 Dec 2024 05:09:13 GMT
< server: istio-envoy
< x-envoy-upstream-service-time: 5966
<
{ [25 bytes data]
100    77  100    25  100    52      4      8  0:00:06  0:00:05  0:00:01     6
* Connection #0 to host 172.29.198.75 left intact
{
  "predictions": [
    "paris"
  ]
}
```
