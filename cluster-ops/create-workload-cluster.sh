#!bin/bash
read -p 'workloadClusterName: ' workloadClusterName
read -p 'mgmtClusterName: ' mgmtClusterName
read -p 'staticIp: ' staticIp
cd /home/ubuntu/
cp /home/ubuntu/eks-anywhere/cluster-samples/workload-eks-a-cluster-sample.yaml /home/ubuntu/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/workloadclustername/$workloadClusterName/g" $workloadClusterName-eks-a-cluster.yaml
sed -i "s/staticIp/$staticIp/g" $workloadClusterName-eks-a-cluster.yaml 
eksctl anywhere create cluster \
  -f /home/ubuntu/$workloadClusterName-eks-a-cluster.yaml  \
  --kubeconfig /home/ubuntu/$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig
