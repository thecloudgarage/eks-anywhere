* Replace the IP address for the OCR HTTPD API service
* Open multiple windows and re-run the command replacing the pod name to execute higher load
```
kubectl run -i --tty load-generator-1 --rm --image=quay.io/quay/busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://172.24.165.21; done"
```
