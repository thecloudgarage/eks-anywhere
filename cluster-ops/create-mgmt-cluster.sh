#!bin/bash
read -p 'mgmtClusterName: ' mgmtClusterName
read -p 'staticIp: ' staticIp
if ping -c 1 $staticIp &> /dev/null
then
  echo "Error., cannot contintue...Static IP conflict, address in use"
else
export $mgmtClusterName
cd /home/ubuntu
cp /home/ubuntu/eks-anywhere/cluster-samples/mgmt-eks-a-cluster-sample.yaml /home/ubuntu/$mgmtClusterName-eks-a-cluster.yaml
sed -i "s/staticIp/$staticIp/g" /home/ubuntu/$mgmtClusterName-eks-a-cluster.yaml
sed -i "s/mgmt/$mgmtClusterName/g" /home/ubuntu/$mgmtClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster -f /home/ubuntu/$mgmtClusterName-eks-a-cluster.yaml
fi
