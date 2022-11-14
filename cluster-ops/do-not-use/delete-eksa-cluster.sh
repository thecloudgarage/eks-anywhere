#!bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "${RED}1. In case of deleting standalone workload or management clusters, keep workload and management cluster EXACTLY THE SAME${NC}"
echo -e "${RED}2. In case of deleting workload clusters managed via a separate management cluster, provide respective cluster names appropriately${NC}"
read -p 'Workload cluster name: ' workloadClusterName
read -p 'Management cluster name: ' mgmtClusterName
if [ "$mgmtClusterName" == "$workloadClusterName" ]
then
cd $HOME
export KUBECONFIG=$HOME/$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
eksctl anywhere delete cluster -f $HOME/$workloadClusterName-eks-a-cluster.yaml
rm -rf $HOME/$workloadClusterName
rm -rf $HOME/$workloadClusterName-eks-a-cluster.yaml
else
cd $HOME
export KUBECONFIG=$HOME/$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
export MANAGEMENT_KUBECONFIG=$HOME/$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig
cd $HOME
eksctl anywhere delete cluster $workloadClusterName --kubeconfig ${MANAGEMENT_KUBECONFIG}
rm -rf $HOME/$workloadClusterName
rm -rf $HOME/$workloadClusterName-eks-a-cluster.yaml
fi
