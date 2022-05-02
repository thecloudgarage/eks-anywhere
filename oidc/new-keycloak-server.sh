#!bin/bash
read -p 'fqdnOfKeycloakServer: ' fqdnOfKeycloakServer
cp /home/ubuntu/eks-anywhere/oidc/sslcert.conf.sample /home/ubuntu/eks-anywhere/oidc/sslcert.conf
cp /home/ubuntu/eks-anywhere/oidc/keycloak.tf.sample /home/ubuntu/eks-anywhere/oidc/keycloak.tf
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" /home/ubuntu/eks-anywhere/oidc/sslcert.conf
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" /home/ubuntu/eks-anywhere/oidc/keycloak.tf
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout tls.key -out tls.crt -config sslcert.conf -extensions 'v3_req'
docker-compose up -d
