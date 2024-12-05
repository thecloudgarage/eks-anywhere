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
kubectl exec -it <pod-name> -- jupyter server list
kubectl get svc
```
* Open the browser for http://external-ip-of-notebook-svc
* Paste the token
* Open a terminal
```
cd $HOME
wget https://github.com/NVIDIA/DALI/archive/refs/heads/main.zip
unzip main.zip
rm -rf main.zip
wget https://github.com/NVIDIA/DALI_extra/archive/refs/heads/main.zip
unzip main.zip
rm -rf main.zip
mv DALI-main DALI
mv mv DALI_extra-main DALI_extra
pip install nvidia-dali-cuda120
pip install nvidia-dali-tf-plugin-cuda120
pip install nvidia-dali-tf-plugin-cuda120
```
Open a new jupyter notebook and click on the DALI directory > docs > examples > getting started
