#!/bin/bash
cd $HOME/eks-anywhere/oidc
terraform init
terraform plan
terraform apply -auto-approve
source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
kubectl apply -f keycloak-rbac.yaml
cd /home/ubuntu
