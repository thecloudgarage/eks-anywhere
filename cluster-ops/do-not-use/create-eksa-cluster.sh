#!bin/bash
echo "Keep workload and management cluster name exactly the same for creating a standalone workload OR a management cluster"
echo "In case you are creating a workload cluster which is managed via an existing management cluster"
echo "then provide the correct name of the existing management cluster"
read -p 'Workload cluster name: ' workloadClusterName
read -p 'Management cluster name: ' mgmtClusterName
read -p 'staticIp for API server High Availability: ' apiServerIpAddress
if ping -c 1 $staticIp &> /dev/null
then
  echo "Error., cannot contintue...Static IP conflict, address in use"
else
if [ "$mgmtClusterName" == "$workloadClusterName" ]
then
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml \
        $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$workloadClusterName/g" $workloadClusterName-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$mgmtClusterName/g" $workloadClusterName-eks-a-cluster.yaml
sed -i "s/api-server-ip/$apiServerIpAddress/g" $workloadClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster -f /home/ubuntu/$workloadClusterName-eks-a-cluster.yaml
else
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml \
        $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$workloadClusterName/g" $workloadClusterName-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$mgmtClusterName/g" $workloadClusterName-eks-a-cluster.yaml
sed -i "s/api-server-ip/$apiServerIpAddress/g" $workloadClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster \
  -f $HOME/$workloadClusterName-eks-a-cluster.yaml  \
  --kubeconfig $HOME/$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig
fi
fi
