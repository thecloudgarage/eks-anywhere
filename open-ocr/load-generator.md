kubectl run -i --tty load-generator-5 --rm --image=quay.io/quay/busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://172.24.165.21; done"
