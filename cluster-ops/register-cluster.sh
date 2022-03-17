#!bin/bash
read -p 'workloadClusterName: ' workloadClusterName
read -sp 'AWS_ACCESS_KEY_ID: ' AWS_ACCESS_KEY_ID
read -sp 'AWS_SECRET_ACCESS_KEY: ' AWS_SECRET_ACCESS_KEY
read -p 'AWS_REGION: ' AWS_REGION
cd /home/ubuntu/$workloadClusterName
mkdir eks-connector && cd eks-connector
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY eksctl register cluster --name $workloadClusterName --provider eks_anywhere
 --region $AWS_REGION
CLUSTER_NAME=$workloadClusterName
KUBECONFIG=/home/ubuntu/$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector.yaml
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector-clusterrole.yaml
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector-console-dashboard-full-access-group.yaml
cd /home/ubuntu
echo "Don't forget to switch the cluster in case you want to interact with $workloadClusterName cluster"
