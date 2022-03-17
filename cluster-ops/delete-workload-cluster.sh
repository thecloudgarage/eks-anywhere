#!bin/bash
read -p 'workloadClusterName: ' workloadClusterName
read -p 'mgmtClusterName: ' mgmtClusterName
cd /home/ubuntu
export KUBECONFIG=$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
export MANAGEMENT_KUBECONFIG=$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig
cd /home/ubuntu
eksctl anywhere delete cluster $workloadClusterName --kubeconfig ${MANAGEMENT_KUBECONFIG}
rm -rf $workloadClusterName
