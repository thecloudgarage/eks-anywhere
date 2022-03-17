#!/bin/bash
read -p 'workloadClusterName: ' workloadClusterName
read -sp 'AWS_ACCESS_KEY_ID: ' AWS_ACCESS_KEY_ID
read -sp 'AWS_SECRET_ACCESS_KEY: ' AWS_SECRET_ACCESS_KEY
read -p 'AWS_REGION: ' AWS_REGION
cd /home/ubuntu/$workloadClusterName
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY eksctl deregister cluster --name $workloadClusterName --region $AWS_REGION
CLUSTER_NAME=$workloadClusterName
KUBECONFIG=/home/ubuntu/$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
kubectl delete -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector.yaml
kubectl delete -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector-clusterrole.yaml
kubectl delete -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector-console-dashboard-full-access-group.yaml
cd /home/ubuntu/$workloadClusterName
rm -rf eks-connector
cd /home/ubuntu
