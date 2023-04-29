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
read -p 'Cluster template filename without extension: ' clusterTemplateFileName
read -p 'Kubernetes version 1.21, 1.22, v1.23, etc.: ' kubernetesVersion
if ping -c 1 $staticIp &> /dev/null
then
  echo "Error., cannot contintue...Static IP conflict, address in use"
else
cp $HOME/eks-anywhere/cluster-samples/$clusterTemplateFileName.yaml $HOME/$workloadClusterName-eks-a-cluster.ya
ml
if [ "$mgmtClusterName" == "$workloadClusterName" ]
then
cd $HOME
sed -i "s/workload-cluster-name/$workloadClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$mgmtClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/api-server-ip/$apiServerIpAddress/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/1.21/$kubernetesVersion/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster -f $HOME/$workloadClusterName-eks-a-cluster.yaml 2> >(grep -v "missing")
else
cd $HOME
sed -i "s/workload-cluster-name/$workloadClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$mgmtClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/api-server-ip/$apiServerIpAddress/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/1.21/$kubernetesVersion/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster \
  -f $HOME/$workloadClusterName-eks-a-cluster.yaml  \
  --kubeconfig $HOME/$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig 2> >(grep -v "missing")
fi
fi
