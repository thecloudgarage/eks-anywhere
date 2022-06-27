#!/bin/bash
read -p 'clusterName: ' clusterName
echo "Provide the API server endpoint in the format https://172.24.165.11:6443"
echo "Ensure that https and port number 6443 is mentioned as specififed in the above format"
echo "Only in cases e.g. eks public clusters, you can omit the port number as it provides a load-balancer URL"
read -p 'apiServerEndpoint: ' apiServerEndpoint
kubectl config --kubeconfig=$HOME/.kube/config set-cluster \
$clusterName --server=$apiServerEndpoint --insecure-skip-tls-verify
