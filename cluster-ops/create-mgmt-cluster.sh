#!bin/bash
read -p 'mgmtClusterName: ' mgmtClusterName
export $mgmtClusterName
cp /home/ubuntu/eks-anywhere/cluster-sample/mgmt-eks-a-cluster-sample.yaml \ 
   /home/ubuntu/cluster-configs/$mgmtClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster -f /home/ubuntu/cluster-configs/$mgmtClusterName-eks-a-cluster.yaml
