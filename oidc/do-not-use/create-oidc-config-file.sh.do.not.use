#!bin/bash
read -p 'fqdnOfKeycloakServer: ' fqdnOfKeycloakServer
echo "Is your KeyCloak server provided with a valid public certificate. Type yes or no"
read -p 'yes/no: ' yesno
cp $HOME/eks-anywhere/oidc/oidc-config.yaml.sample $HOME/eks-anywhere/oidc/oidc-config.yaml
if [ "$yesno" = "yes" ]
then
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" $HOME/eks-anywhere/oidc/oidc-config.yaml
sed -i '/oidc-ca-file/d' $HOME/eks-anywhere/oidc/oidc-config.yaml
else
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" $HOME/eks-anywhere/oidc/oidc-config.yaml
fi
