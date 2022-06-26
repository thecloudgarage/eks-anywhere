#!/bin/bash
read -p 'fqdnOfKeycloakServer: ' fqdnOfKeycloakServer
cd $HOME/eks-anywhere/oidc
cp keycloak.tf.sample keycloak.tf
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" $HOME/eks-anywhere/oidc/keycloak.tf
terraform init
terraform plan
terraform apply -auto-approve
source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
kubectl apply -f keycloak-rbac.yaml
cd /home/ubuntu
