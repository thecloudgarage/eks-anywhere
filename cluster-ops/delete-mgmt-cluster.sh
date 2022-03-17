#!bin/bash
read -p 'mgmtClusterName: ' mgmtClusterName
export CLUSTER_NAME=$mgmtClusterName
export CONFIG_FILE=/home/ubuntu/cluster-configs/$mgmtClusterName-eks-a-cluster.yaml
cd /home/ubuntu
eksctl anywhere delete cluster -f ${CONFIG_FILE}
rm -rf /home/ubuntu/$CLUSTER_NAME
