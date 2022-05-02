#!/bin/bash
cd /home/ubuntu/eks-anywhere/oidc
terraform init
terraform plan
terraform apply -auto-approve
source /home/ubuntu/eks-anywhere/cluster-ops/switch-cluster.sh
kubectl apply -f keycloak-rbac.yaml
cd /home/ubuntu
