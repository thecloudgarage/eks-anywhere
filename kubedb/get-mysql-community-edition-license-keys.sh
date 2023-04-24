#!/bin/bash
echo "Enter your Kube DB API Token"
read -sp 'kubeDbApiToken: ' kubeDbApiToken
echo "Enter your name"
read -p 'name: ' name
echo "Enter your registered Email with KubeDB"
read -p 'emailAddress: ' emailAddress
clusterId=$(kubectl get ns kube-system -o=jsonpath='{.metadata.uid}')
curl -X POST \
-d "name=$name&email=$emailAddress&product=kubedb-community&cluster=$clusterId&tos=true&token=$kubeDbApiToken" \
https://license-issuer.appscode.com/issue-license > $CLUSTER_NAME/$CLUSTER_NAME-mysql-kubedb-license-key.txt
