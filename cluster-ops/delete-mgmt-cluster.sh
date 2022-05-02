#!bin/bash
read -p 'mgmtClusterName: ' mgmtClusterName
export KUBECONFIG=/home/ubuntu/$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig
cd /home/ubuntu
eksctl anywhere delete cluster -f /home/ubuntu/$mgmtClusterName-eks-a-cluster.yaml
rm -rf /home/ubuntu/$mgmtClusterName
rm -rf /home/ubuntu/$mgmtClusterName-eks-a-cluster.yaml
