#!/bin/bash
kubectl delete -f complete-demo-with-persistence.yaml
kubectl delete -f ingress-sockshop.yaml
kubectl delete secret sockshop -n sock-shop
sleep 60
kubectl delete ns sock-shop
kubectl delete -f ingress-controller-nginx.yaml
sleep 20
rm -rf ingress-sockshop.yaml
rm -rf tls*
rm -rf sslcert.conf
