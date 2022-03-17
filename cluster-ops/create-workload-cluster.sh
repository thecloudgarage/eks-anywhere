#!bin/bash
read -p 'workloadClusterName: ' workloadClusterName
read -p 'mgmtClusterName: ' mgmtClusterName
cd /home/ubuntu/
cp /home/ubuntu/eks-anywhere/cluster-samples/workload-eks-a-cluster-sample.yaml \ 
   /home/ubuntu/cluster-configs/$workloadClusterName-eks-a-cluster.yaml
sed -i 's/w01/$workloadClusterName/g' 
eksctl anywhere create cluster \
  -f /home/ubuntu/cluster-configs/$workloadClusterName-eks-a-cluster.yaml  \
  --kubeconfig $mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig
