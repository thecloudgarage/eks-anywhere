#!bin/bash
read -p 'fqdnOfSockShopFrontEnd: ' fqdnOfSockShopFrontEnd
cd $HOME/eks-anywhere/sock-shop/
cp ./sslcert.conf.sample ./sslcert.conf
sed -i "s/fqdnOfSockShopFrontEnd/$fqdnOfSockShopFrontEnd/g" ./sslcert.conf
cp ./ingress-sockshop.yaml.sample ./ingress-sockshop.yaml
sed -i "s/fqdnOfSockShopFrontEnd/$fqdnOfSockShopFrontEnd/g" ./ingress-sockshop.yaml
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout tls.key -out tls.crt -config sslcert.conf -extensions 'v3_req'
kubectl create -f $HOME/eks-anywhere/sock-shop/namespace-sockshop.yaml
sleep 3
kubectl create secret tls sockshop-tls -n sock-shop --key tls.key --cert tls.crt
sleep 3
kubectl create -f $HOME/eks-anywhere/ingress-controllers/nginx-ingress-controller-eks-nlb.yaml
sleep 120
kubectl create -f $HOME/eks-anywhere/ingress-controllers/nginx-ingress-class.yaml
sed 's/powerstore-ext4/ebs-sc/g' $HOME/eks-anywhere/sock-shop/complete-demo-with-persistence.yaml
sed 's/8Gi/1Gi/g' $HOME/eks-anywhere/sock-shop/complete-demo-with-persistence.yaml
kubectl create -f $HOME/eks-anywhere/sock-shop/complete-demo-with-persistence.yaml
sleep 60
kubectl create -f $HOME/eks-anywhere/sock-shop/ingress-sockshop.yaml
