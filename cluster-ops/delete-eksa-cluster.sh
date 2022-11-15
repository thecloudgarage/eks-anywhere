#!bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "${RED}#######################IMPORTANT NOTE#################################${NC}"
echo -e "${RED}keep the name of workload and management cluster EXACTLY THE SAME${NC}"
echo -e "${RED}in case of deleting standlone workload clusters or management clusters${NC}"
echo -e "${RED}######################################################################${NC}"
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
