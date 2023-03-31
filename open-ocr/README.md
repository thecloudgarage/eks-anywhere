* Download manifests
```
cd $HOME
rm -rf open-ocr
mkdir open-ocr
mkdir open-ocr/manifests
cd $HOME/open-ocr/manifests
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/open-ocr/bootstrap.sh
chmox +x boostrap.sh
cd open-ocr/manifests
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/open-ocr/manifests/links.txt
wget -i links.txt
```
### Deploy cluster autoscaler manifest
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
