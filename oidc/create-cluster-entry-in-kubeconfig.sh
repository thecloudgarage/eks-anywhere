#!/bin/bash
read -p 'clusterName: ' clusterName
echo "Provide the Static IP address of the Cluster's API server. Append the port number if required, i.e. 6443"
read -p 'apiServerEndpoint: ' apiServerEndpoint
kubectl config --kubeconfig=$HOME/.kube/config set-cluster \
$clusterName --server=$apiServerEndpoint --insecure-skip-tls-verify
