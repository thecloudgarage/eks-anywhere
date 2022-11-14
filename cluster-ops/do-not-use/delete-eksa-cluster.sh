#!bin/bash
echo "Keep workload and management cluster name exactly the same for deleting a standalone workload OR a management cluster"
echo "In case you are deleting a workload cluster which is managed via an existing management cluster"
echo "then provide the correct name of the existing workload and its respective management cluster"
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
