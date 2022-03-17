#!bin/bash
read -p 'mgmtClusterName: ' mgmtClusterName
export $mgmtClusterName
eksctl anywhere create cluster -f /home/ubuntu/cluster-configs/eks-a-$mgmtClusterName-cluster.yaml
