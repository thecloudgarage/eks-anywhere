#!bin/bash
read -p 'mgmtClusterName: ' mgmtClusterName
export KUBECONFIG=$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig
cd /home/ubuntu
eksctl anywhere delete cluster -f /home/ubuntu/$mgmtClusterName-eks-a-cluster.yaml
rm -rf /home/ubuntu/$mgmtClusterName
