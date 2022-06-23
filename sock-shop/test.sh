#!bin/bash
read -p 'fqdnOfSockShopFrontEnd: ' fqdnOfSockShopFrontEnd
read -p 'METALLB_IP_START: ' METALLB_IP_START
read -p 'METALLB_IP_END: ' METALLB_IP_END
METALLB_IP_RANGE="$METALLB_IP_START-$METALLB_IP_END"
helm upgrade --install --wait --timeout 15m \
  --namespace metallb-system --create-namespace \
  --repo https://metallb.github.io/metallb metallb metallb \
  --values - <<EOF
configInline:
  address-pools:
  - name: default
    protocol: layer2
    addresses:
    - ${METALLB_IP_RANGE}
EOF
cp ./sslcert.conf.sample ./sslcert.conf
sed -i "s/fqdnOfSockShopFrontEnd/$fqdnOfSockShopFrontEnd/g" ./sslcert.conf
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout tls.key -out tls.crt -config sslcert.conf -extensions 'v3_req'
kubectl create -f namespace-sock-shop.yaml
kubectl create -f ingress-controller-nginx.yaml
kubectl create -f complete-demo-with-persistence.yaml
cp ./ingress-front-end.yaml.sample ./ingress-front-end.yaml
sed -i "s/fqdnOfSockShopFrontEnd/$fqdnOfSockShopFrontEnd/g" ./ingress-front-end.yaml
kubectl create -f ingress-front-end.yaml
