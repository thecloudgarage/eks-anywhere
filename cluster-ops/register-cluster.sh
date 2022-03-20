#!bin/bash
read -p 'workloadClusterName: ' workloadClusterName
read -sp 'AWS_ACCESS_KEY_ID: ' AWS_ACCESS_KEY_ID
read -sp 'AWS_SECRET_ACCESS_KEY: ' AWS_SECRET_ACCESS_KEY
read -p 'AWS_REGION: ' AWS_REGION
cd /home/ubuntu/$workloadClusterName
if AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
        eksctl register cluster --name $workloadClusterName --provider eks_anywhere --region $AWS_REGION > /dev/null 2>&1
then
CLUSTER_NAME=$workloadClusterName
KUBECONFIG=/home/ubuntu/$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
mkdir eks-connector
mv eks-connector.yaml eks-connector/
mv eks-connector-clusterrole.yaml eks-connector/
mv eks-connector-console-dashboard-full-access-group.yaml eks-connector/
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector.yaml
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector-clusterrole.yaml
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector-console-dashboard-full-access-group.yaml
cd /home/ubuntu
echo "Don't forget to switch the cluster in case you want to interact with $workloadClusterName cluster"
#
#
else
echo "DON'T FRET SERVICE-ROLE PROPAGATION IS IN PROGRESS, WAIT FOR 30 SECONDS"
echo "DON'T FRET SERVICE-ROLE PROPAGATION IS IN PROGRESS, WAIT FOR 30 SECONDS"
echo "DON'T FRET SERVICE-ROLE PROPAGATION IS IN PROGRESS, WAIT FOR 30 SECONDS"
sleep 30
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
        eksctl register cluster --name $workloadClusterName --provider eks_anywhere --region $AWS_REGION
CLUSTER_NAME=$workloadClusterName
KUBECONFIG=/home/ubuntu/$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
mkdir eks-connector
mv eks-connector.yaml eks-connector/
mv eks-connector-clusterrole.yaml eks-connector/
mv eks-connector-console-dashboard-full-access-group.yaml eks-connector/
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector.yaml
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector-clusterrole.yaml
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector-console-dashboard-full-access-group.yaml
cd /home/ubuntu
echo "DON'T FORGET TO SWITCH TO THE  $workloadClusterName CLUSTER"
echo "DON'T FORGET TO SWITCH TO THE  $workloadClusterName CLUSTER"
echo "DON'T FORGET TO SWITCH TO THE  $workloadClusterName CLUSTER"
fi
