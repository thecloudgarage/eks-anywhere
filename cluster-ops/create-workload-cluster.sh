#!bin/bash
read -p 'workloadClusterName: ' workloadClusterName
read -p 'mgmtClusterName: ' mgmtClusterName
cd /home/ubuntu/
cp 
sed -i 's/w01/$workloadClusterName/g' 
eksctl anywhere create cluster \
  -f /home/ubuntu/cluster-configs/eks-a-$workloadClusterName-cluster.yaml  \
  --kubeconfig $mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig
