#!/bin/bash
read -p 'fqdnOfKeycloakServer: ' fqdnOfKeycloakServer
read -p 'emailDomainName: ' emailDomainName
cd $HOME/eks-anywhere/oidc
cp keycloak.tf.sample keycloak.tf
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" $HOME/eks-anywhere/oidc/keycloak.tf
sed -i "s/emailDomainNamer/$emailDomainName/g" $HOME/eks-anywhere/oidc/keycloak.tf
terraform init
terraform plan
terraform apply -auto-approve
