
Deploy a minio or any S3 compatible storage on a docker host. Example:
```
rm -rf $HOME/minio
mkdir -p $HOME/minio/minio_data
cd minio
cat <<EOF > docker-compose.yaml
version: '3'
services:
  minio:
    image: docker.io/bitnami/minio:2022
    ports:
      - '9000:9000'
      - '9001:9001'
    networks:
      - minionetwork
    volumes:
      - './minio_data:/data'
    environment:
      - MINIO_ROOT_USER=minio
      - MINIO_ROOT_PASSWORD=minio@1234
networks:
  minionetwork:
    driver: bridge
volumes:
  minio_data:
    driver: local
EOF
docker-compose up -d
```
* Create a bucket in Mino named "bloom"
* Create the IAM user and retrive the access key Id and secret access key
* Create a secret and service account in the k8s cluster for the S3 compatible storage
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: s3creds
  annotations:
     serving.kserve.io/s3-endpoint: 172.29.198.74:9000 # replace with your s3 endpoint 
     serving.kserve.io/s3-usehttps: "0" # by default 1, if testing with minio you can set to 0
     serving.kserve.io/s3-region: "us-east-1"
     serving.kserve.io/s3-useanoncredential: "false" # omitting this is the same as false, if true will ignore provided credential and use anonymous credentials
type: Opaque
stringData: 
  AWS_ACCESS_KEY_ID: D4Vvb1y8r85UwSst
  AWS_SECRET_ACCESS_KEY: fY9nFaPFNaLqpHbEL7CfiPh57S664rDh
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa
secrets:
- name: s3creds
EOF
```
Download the sample model from kserve google cloud storage bucket and copy it to the local S3 compatible storage. Ensure AWS credentials are created for the local S3 storage
```
cd $HOME
wget https://storage.googleapis.com/pub/gsutil.tar.gz
tar xfz gsutil.tar.gz -C $HOME
export PATH=${PATH}:$HOME/gsutil
mkdir -p bloom
gsutil cp gs://kfserving-examples/models/torchserve/llm/Huggingface_accelerate/bloom $HOME/bloom/
aws --endpoint-url http://172.29.198.74:9000 s3 cp bloom s3://bloom --recursive
```
Deploy a kserve inference service
```
cat <<EOF | kubectl apply -f -
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: "bloom7b1"
spec:
  predictor:
    serviceAccountName: sa
    pytorch:
      runtimeVersion: 0.8.2
      storageUri: s3://bloom
      resources:
        limits:
          cpu: "2"
          memory: 32Gi
          nvidia.com/gpu: "1"
        requests:
          cpu: "2"
          memory: 32Gi
          nvidia.com/gpu: "1"
EOF
```
Observe the Storage init container associated with the Inference service pod
```
kubectl get inferenceservice
NAME         URL   READY     PREV   LATEST   PREVROLLEDOUTREVISION   LATESTREADYREVISION   AGE
bloom7b1         Unknown
                                                                7s
kubectl get pods
NAME                                                    READY   STATUS     RESTARTS   AGE
bloom7b1-4-predictor-00001-deployment-59d6d4b79-w9xrc   0/2     Init:0/1   0          9s

kubectl logs bloom7b1-4-predictor-00001-deployment-59d6d4b79-w9xrc -c storage-initializer

2024-11-27 09:52:04.830 1 kserve INFO [initializer-entrypoint:<module>():16] Initializing, args: src_uri [s3://kserve] dest_path[ [/mnt/models]
2024-11-27 09:52:04.831 1 kserve INFO [storage.py:download():66] Copying contents of s3://bloom to local
2024-11-27 09:52:04.958 1 kserve INFO [storage.py:_download_s3():262] Downloaded object config/config.properties to /mnt/models/config/config.properties

kubectl get inferenceservice
NAME         URL                                 READY   PREV   LATEST   PREVROLLEDOUTREVISION   LATESTREADYREVISION          AGE
bloom7b1   http://bloom7b1.default.example.com   True           100                              bloom7b1-4-predictor-00001   13m4s








