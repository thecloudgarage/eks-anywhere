#!bin/bash
echo "IS THIS WORKLOAD CLUSTER MANAGED BY A DEDICATED MANAGEMENT CLUSTER, if not then leave mgmtClusterName BLANK"
read -p 'workloadClusterName: ' workloadClusterName
read -p 'mgmtClusterName: ' mgmtClusterName
if [ -z "$mgmtClusterName" ]
then
cd /home/ubuntu
export KUBECONFIG=/home/ubuntu/$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
eksctl anywhere delete cluster -f /home/ubuntu/$workloadClusterName-eks-a-cluster.yaml
rm -rf /home/ubuntu/$workloadClusterName
rm -rf /home/ubuntu/$workloadClusterName-eks-a-cluster.yaml
else
cd /home/ubuntu
export KUBECONFIG=/home/ubuntu/$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
export MANAGEMENT_KUBECONFIG=/home/ubuntu/$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig
cd /home/ubuntu
eksctl anywhere delete cluster $workloadClusterName --kubeconfig ${MANAGEMENT_KUBECONFIG}
rm -rf /home/ubuntu/$workloadClusterName
rm -rf /home/ubuntu/$workloadClusterName-eks-a-cluster.yaml
fi
