### Install NVIDIA GPU operator
```
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator
```
### Install MetalLB
```
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb --wait --timeout 15m --namespace metallb-system --create-namespace
```
### Configure MetalLB
```
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
        env:
        - name: JUPYTER_ENABLE_LAB
          value: "yes"
        - name: GRANT_SUDO #Required for Sudo access
          value: "yes"
        - name: DALI_EXTRA_PATH
          value: "/home/jovyan/DALI_extra"
        securityContext: #Required to run as root
          runAsUser: 0 
          runAsGroup: 0   
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
pip install --extra-index-url https://pypi.nvidia.com --upgrade nvidia-dali-cuda120
pip install --extra-index-url https://pypi.nvidia.com --upgrade nvidia-dali-tf-plugin-cuda120
pip install nvidia-nvjpeg-cu12
sudo apt update -y
sudo apt-get install git-lfs -y
git clone https://github.com/NVIDIA/DALI.git
git clone https://github.com/NVIDIA/DALI_extra.git
```






### Workaround if sudo is not working as the DALI_extra has huge files and requires git-lfs
```
cd $HOME
wget https://github.com/NVIDIA/DALI_extra/archive/refs/tags/v1.44.0.zip -O DALI.zip
wget https://github.com/NVIDIA/DALI_extra/archive/refs/tags/v1.44.0.zip -O DALI_extra.zip
unzip DALI-test.zip
unzip DALI_extra.zip
```
* Open a new jupyter notebook and click on the DALI directory > docs > examples > getting started
* In the other notebooks in examples > image_processing, please change the value of
```
FROM
test_data_root = os.environ["DALI_EXTRA_PATH"]
  
TO
test_data_root = "/home/jovyan/DALI_extra-1.44.0"
