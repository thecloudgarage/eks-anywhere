#!/bin/bash
kubectl delete -f $HOME/eks-anywhere/sock-shop/complete-demo-with-persistence-aws.yaml
kubectl delete -f $HOME/eks-anywhere/sock-shop/ingress-sockshop.yaml
kubectl delete secret sockshop-tls -n sock-shop
sleep 60
kubectl delete ns sock-shop
kubectl delete -f $HOME/eks-anywhere/ingress-controllers/nginx-ingress-class.yaml
kubectl delete -f $HOME/eks-anywhere/ingress-controllers/nginx-ingress-controller-eks-nlb.yaml
sleep 20
rm -rf $HOME/eks-anywhere/sock-shop/ingress-sockshop.yaml
rm -rf tls*
rm -rf sslcert.conf
