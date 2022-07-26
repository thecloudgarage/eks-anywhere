#!bin/bash
cd $HOME/eks-anywhere/oidc
read -p 'fqdnOfKeycloakServer: ' fqdnOfKeycloakServer
cp $HOME/eks-anywhere/oidc/sslcert.conf.sample $HOME/eks-anywhere/oidc/sslcert.conf
cp $HOME/eks-anywhere/oidc/keycloak.tf.sample $HOME/eks-anywhere/oidc/keycloak.tf
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" $HOME/eks-anywhere/oidc/sslcert.conf
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" $HOME/eks-anywhere/oidc/keycloak.tf.sample
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout tls.key -out tls.crt -config sslcert.conf -extensions 'v3_req'
cp $HOME/eks-anywhere/oidc/tls.crt $HOME/eks-anywhere/oidc/keycloak.pem
docker-compose up -d
