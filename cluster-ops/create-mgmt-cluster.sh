#!bin/bash
read -p 'mgmtClusterName: ' mgmtClusterName
export $mgmtClusterName
eksctl anywhere create cluster -f /home/ubuntu/cluster-configs/$mgmtClusterName-eks-a-cluster-sample.yaml
