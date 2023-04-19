### Deploy EKS Anywhere Kubernetes cluster with auto-scaling attributes
### Deploy MetalLB Software Defined Load Balancer
```
helm upgrade --install --wait --timeout 15m   --namespace metallb-system --create-namespace   --repo https://metallb.github.io/metallb metallb metallb
```
### Configure MetalLB load balancer
```
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
```
### Download manifests
```
cd $HOME
rm -rf open-ocr
mkdir open-ocr
mkdir open-ocr/manifests
cd $HOME/open-ocr/
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/open-ocr/bootstrap.sh
chmox +x boostrap.sh
cd $HOME/open-ocr/manifests
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/open-ocr/manifests/links.txt
wget -i links.txt
```
### Deploy cluster autoscaler manifest
First edit line 26 in the manifest file to change the cluster name
```
kubectl apply -f $HOME/open-ocr/manifests/eksa-cluster-autoscaler.yaml
```
### Deploy metrics-server
```
kubectl apply -f $HOME/open-ocr/manifests/metrics-server.yaml
```

### Deploy Open OCR application
```
cd $HOME/open-ocr
./bootstrap.sh -c
./bootstrap.sh -i
```
### Validate Open OCR application
Image-1
```
curl -X POST http://172.24.165.21:80/ocr -H "Content-Type: application/json" -d '{"img_url":"https://s3.amazonaws.com/walnuteks.thecloudgarage.com/open-ocr/image1.png","engine":"tesseract"}' 
```
Image-2
```
curl -X POST http://172.24.165.21:80/ocr -H "Content-Type: application/json" -d '{"img_url":"https://s3.amazonaws.com/walnuteks.thecloudgarage.com/open-ocr/image2.png","engine":"tesseract"}' 
```
Image-3
```
curl -X POST http://172.24.165.21:80/ocr -H "Content-Type: application/json" -d '{"img_url":"https://s3.amazonaws.com/walnuteks.thecloudgarage.com/open-ocr/image3.png","engine":"tesseract"}' 
```
### Deploy Horizontal Pod Autoscaler for OCR HTTPD session
```
kubectl apply -f cd $HOME/open-ocr/manifests/hpa-open-ocr-httpd.yaml
```
### Observe base-line 
```
kubectl get pods
kubectl get nodes
kubectl get hpa
kubectl top pods
kubectl top nodes
```
### Run load generator session-1
* Open a new terminal
```
kubectl run -i --tty load-generator-1 --rm --image=quay.io/quay/busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://172.24.165.21; done"
```
* Watch the new state
```
kubectl get pods
kubectl get nodes
kubectl get hpa
kubectl top pods
kubectl top nodes
```
### Run load generator session-2
* Open a new terminal
```
kubectl run -i --tty load-generator-2 --rm --image=quay.io/quay/busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://172.24.165.21; done"
```
* Watch the new state
```
kubectl get pods
kubectl get nodes
kubectl get hpa
kubectl top pods
kubectl top nodes
```
### Run load generator session-3
* Open a new terminal
```
kubectl run -i --tty load-generator-3 --rm --image=quay.io/quay/busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://172.24.165.21; done"
```
* Watch the new state
```
kubectl get pods
kubectl get nodes
kubectl get hpa
kubectl top pods
kubectl top nodes
```
