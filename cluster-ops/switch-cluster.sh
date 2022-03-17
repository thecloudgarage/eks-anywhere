#!/bin/bash
read -p 'clusterName: ' clusterName
echo $clusterName
sed -i '/^CLUSTER/d' /home/ubuntu/.profile
sed -i '/^KUBECONFIG/d' /home/ubuntu/.profile
echo "CLUSTER_NAME=$clusterName; export CLUSTER_NAME" >> ~/.profile
echo "KUBECONFIG=/home/ubuntu/$clusterName/$clusterName-eks-a-cluster.kubeconfig; export KUBECONFIG" >> ~/.profile
source ~/.profile
