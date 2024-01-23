#!/bin/bash
echo "Enter your Kube DB API Token"
#read -sp 'kubeDbApiToken: ' kubeDbApiToken
echo "Enter your EKS ANYWHERE name"
read -p 'CLUSTER_NAME: ' CLUSTER_NAME
echo "Enter your name"
read -p 'name: ' name
echo "Enter your registered Email with KubeDB"
read -p 'emailAddress: ' emailAddress
clusterId=$(kubectl get ns kube-system -o=jsonpath='{.metadata.uid}')
#curl -X POST \
#-d "name=$name&email=$emailAddress&product=kubedb-enterprise&cluster=$clusterId&tos=true&token=$kubeDbApiToken" \
#https://license-issuer.appscode.com/issue-license > $HOME/$CLUSTER_NAME/$CLUSTER_NAME-kubedb-license-key.txt
source ~/.profile
curl -X POST \
-d "name=$name&email=$emailAddress&product=kubedb-enterprise&cluster=$clusterId&tos=true&token=$APPSCODE_API_TOKEN" \
https://license-issuer.appscode.com/issue-license > $HOME/$CLUSTER_NAME/$CLUSTER_NAME-kubedb-license-key.txt
