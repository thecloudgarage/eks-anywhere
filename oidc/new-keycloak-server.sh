#!bin/bash
read -p 'fqdnOfKeycloakServer: ' fqdnOfKeycloakServer
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" /home/ubuntu/eks-anywhere/oidc/sslcert.conf
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" /home/ubuntu/eks-anywhere/oidc/keycloak.tf
docker-compose up -d
