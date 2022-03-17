#!bin/bash
read -p 'mgmtClusterName: ' mgmtClusterName
export CLUSTER_NAME=$mgmtClusterName
cd /home/ubuntu
eksctl anywhere delete cluster $CLUSTER_NAME
rm -rf /home/ubuntu/$CLUSTER_NAME
