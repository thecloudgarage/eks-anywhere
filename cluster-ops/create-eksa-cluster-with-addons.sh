#!bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "${RED}#######################IMPORTANT NOTE#################################${NC}"
echo -e "${RED}keep the name of workload and management cluster EXACTLY THE SAME${NC}"
echo -e "${RED}in case of creating standlone workload clusters or management clusters${NC}"
echo -e "${RED}######################################################################${NC}"
read -p 'Workload cluster name: ' workloadClusterName
read -p 'Management cluster name: ' mgmtClusterName
read -p 'staticIp for API server High Availability: ' apiServerIpAddress
echo -e "${RED}#######################IMPORTANT NOTE#################################${NC}"
echo -e "${RED}Please copy the filename of the template intended for the cluster${NC}"
echo -e "${RED}######################################################################${NC}"
ls $HOME/eks-anywhere/cluster-samples/*.y* |xargs -n1 basename
read -p 'Cluster template filename: ' clusterTemplateFileName
read -p 'Kubernetes version 1.21, 1.22, 1.23, etc.: ' kubernetesVersion
if ping -c 1 $apiServerIpAddress &> /dev/null
then
  echo "Error., cannot contintue...Static IP conflict, address in use"
else
if [ "$mgmtClusterName" == "$workloadClusterName" ]
then
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/$clusterTemplateFileName $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$workloadClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$mgmtClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/api-server-ip/$apiServerIpAddress/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/1.21/$kubernetesVersion/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster -f $HOME/$workloadClusterName-eks-a-cluster.yaml &> >(grep -v 'Curated\|missing\|Subscription\|curated')
else
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/$clusterTemplateFileName $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$workloadClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$mgmtClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/api-server-ip/$apiServerIpAddress/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/1.21/$kubernetesVersion/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster \
  -f $HOME/$workloadClusterName-eks-a-cluster.yaml  \
  --kubeconfig $HOME/$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig &> >(grep -v 'Curated\|missing\|Subscription\|curated')
fi
fi
