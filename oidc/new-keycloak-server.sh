#!bin/bash
read -p 'fqdnOfKeycloakServer: ' fqdnOfKeycloakServer
cp $HOME/eks-anywhere/oidc/sslcert.conf.sample $HOME/eks-anywhere/oidc/sslcert.conf
cp $HOME/eks-anywhere/oidc/keycloak.tf.sample $HOME/eks-anywhere/oidc/keycloak.tf
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" $HOME/eks-anywhere/oidc/sslcert.conf
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" $HOME/eks-anywhere/oidc/keycloak.tf
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout tls.key -out tls.crt -config sslcert.conf -extensions 'v3_req'
docker-compose up -d
