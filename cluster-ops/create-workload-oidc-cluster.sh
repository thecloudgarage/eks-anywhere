#!bin/bash
echo "IS THIS WORKLOAD CLUSTER MANAGED BY A DEDICATED MANAGEMENT CLUSTER, if not then leave mgmtClusterName BLANK"
read -p 'mgmtClusterName: ' mgmtClusterName
read -p 'workloadClusterName: ' workloadClusterName
read -p 'staticIp for API server High Availability: ' staticIp
if ping -c 1 $staticIp &> /dev/null
then
  echo "Error., cannot contintue...Static IP conflict, address in use"
else
if [ -z "$mgmtClusterName" ]
then
cd /home/ubuntu/
cp /home/ubuntu/eks-anywhere/cluster-samples/workload-eks-a-oidc-cluster-sample.yaml \
        /home/ubuntu/$workloadClusterName-eks-a-oidc-cluster.yaml
sed -i "s/workloadclustername/$workloadClusterName/g" $workloadClusterName-eks-a-oidc-cluster.yaml
sed -i "s/staticIp/$staticIp/g" $workloadClusterName-eks-a-oidc-cluster.yaml
eksctl anywhere create cluster -f /home/ubuntu/$workloadClusterName-eks-a-oidc-cluster.yaml
else
cd /home/ubuntu/
cp /home/ubuntu/eks-anywhere/cluster-samples/workload-eks-a-cluster-oidc-sample.yaml \
        /home/ubuntu/$workloadClusterName-eks-a-oidc-cluster.yaml
sed -i "s/workloadclustername/$workloadClusterName/g" $workloadClusterName-eks-a-oidc-cluster.yaml
sed -i "s/staticIp/$staticIp/g" $workloadClusterName-eks-a-oidc-cluster.yaml
eksctl anywhere create cluster \
  -f /home/ubuntu/$workloadClusterName-eks-a-oidc-cluster.yaml  \
  --kubeconfig /home/ubuntu/$mgmtClusterName/$mgmtClusterName-eks-a-oidc-cluster.kubeconfig
fi
fi
