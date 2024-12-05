### Deploy a Cuda Enabled TensorFlow packaged Jupyter Notebook instance
Jupyter notebook image is used from https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html and more specifically the CUDA enabled image with TensorFlow
```
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notebook-instance
  labels:
    name: notebook-instance
  namespace: default
spec:
  selector:
    matchLabels:
      name: notebook-instance
  replicas: 1
  template:
    metadata:
      labels:
        name: notebook-instance
    spec:
      containers:
      - name: notebook-instance
        image: quay.io/jupyter/tensorflow-notebook:cuda-latest
        ports:
        - containerPort: 8888
        securityContext:
          allowPrivilegeEscalation: false
          runAsUser: 0      
        resources:
          limits:
            cpu: "1"
            memory: 8Gi
            nvidia.com/gpu: "2"
          requests:
            cpu: "1"
            memory: 8Gi
            nvidia.com/gpu: "2"  
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: notebook-instance-svc
  namespace: default
spec:
  selector:
    name: notebook-instance
  ports:
  - port: 80
    targetPort: 8888
    protocol: TCP
  type: LoadBalancer
EOF
```
Retrieve the token and External IP for the notebook service
```
kubectl get pods
POD=$(kubectl get pod -l name=notebook-instance -o jsonpath="{.items[0].metadata.name}")
kubectl exec -it $POD -- jupyter server list
kubectl get svc
```
* Open the browser for http://external-ip-of-notebook-svc
* Paste the token
* Open a terminal
```
cd $HOME
wget https://github.com/NVIDIA/DALI_extra/archive/refs/tags/v1.44.0.zip -O DALI.zip
wget https://github.com/NVIDIA/DALI_extra/archive/refs/tags/v1.44.0.zip -O DALI_extra.zip
unzip DALI-test.zip
unzip DALI_extra.zip
pip install nvidia-dali-cuda120
pip install nvidia-dali-tf-plugin-cuda120
pip install nvidia-nvjpeg-cu12
```
* Open a new jupyter notebook and click on the DALI directory > docs > examples > getting started
* In the other notebooks in examples > image_processing, please change the value of
```
FROM
test_data_root = os.environ["DALI_EXTRA_PATH"]
  
TO
test_data_root = "/home/jovyan/DALI_extra-1.44.0"
