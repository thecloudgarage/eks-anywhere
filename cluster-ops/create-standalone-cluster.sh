#!bin/bash
read -p 'standaloneClusterName: ' standaloneClusterName
read -p 'staticIp: ' staticIp
if ping -c 1 $staticIp &> /dev/null
then
  echo "Error., cannot contintue...Static IP conflict, address in use"
else
export $standaloneClusterName
cd /home/ubuntu
cp /home/ubuntu/eks-anywhere/cluster-samples/standalone-eks-a-cluster-sample.yaml /home/ubuntu/$standaloneClusterName-eks-a-cluster.yaml
sed -i "s/staticIp/$staticIp/g" /home/ubuntu/$standaloneClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster -f /home/ubuntu/$standaloneClusterName-eks-a-cluster.yaml
fi
