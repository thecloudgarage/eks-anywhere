#!bin/bash
read -p 'clusterName: ' clusterName
read -p 'fqdnOfKeycloakServer: ' fqdnOfKeycloakServer
echo "Is your KeyCloak server provided with a valid public certificate. Type yes or no"
read -p 'yes/no: ' yesno
cp $HOME/eks-anywhere/oidc/oidc-config.yaml.sample $HOME/$clusterName/oidc-config.yaml
echo -n | openssl s_client -connect $fqdnOfKeycloakServer:443 -servername $fqdnOfKeycloakServer \
    | openssl x509 > $HOME/eks-anywhere/oidc/$fqdnOfKeycloakServer.crt
if [ "$yesno" = "no" ]
then
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" $HOME/$clusterName/oidc-config.yaml
HOSTS=$(kubectl get nodes --selector='node-role.kubernetes.io/master' \
    -o template \
    --template='{{range.items}}{{range.status.addresses}}{{if eq .type "ExternalIP"}}{{.address}}{{end}}{{end}} {{end}}')
keycloakCert=$(cat $HOME/eks-anywhere/oidc/$fqdnOfKeycloakServer.crt | base64 -w 0)
oidcConfig=$(cat $HOME/$clusterName/oidc-config.yaml | base64 -w 0)
for HOST in $HOSTS
do
ssh \
    -o StrictHostKeyChecking=no \
    -t \
    -i $HOME/$clusterName/eks-a-id_rsa \
    capv@$HOST \
    "sudo echo $keycloakCert > keycloakbase64.crt && cat keycloakbase64.crt | base64 --decode > keycloak.crt \
    && sudo cp keycloak.crt /usr/local/share/ca-certificates && sudo update-ca-certificates \
    && sudo echo $oidcConfig > oidcConfigbase64.yaml && cat oidcConfigbase64.yaml | base64 --decode > oidcConfig.yaml \
    && sudo sed -i '/tls-private-key-file/r oidcConfig.yaml' \
    /etc/kubernetes/manifests/kube-apiserver.yaml"
sleep 60
done
else
sed -i "s/fqdnOfKeycloakServer/$fqdnOfKeycloakServer/g" $HOME/$clusterName/oidc-config.yaml
sed -i '/oidc-ca-file/d' $HOME/$clusterName/oidc-config.yaml
HOSTS=$(kubectl get nodes --selector='node-role.kubernetes.io/master' \
    -o template \
    --template='{{range.items}}{{range.status.addresses}}{{if eq .type "ExternalIP"}}{{.address}}{{end}}{{end}} {{end}}')
oidcConfig=$(cat $HOME/$clusterName/oidc-config.yaml | base64 -w 0)
for HOST in $HOSTS
do
ssh \
    -o StrictHostKeyChecking=no \
    -t \
    -i $HOME/$clusterName/eks-a-id_rsa \
    capv@$HOST \
    "sudo echo $oidcConfig > oidcConfigbase64.yaml && cat oidcConfigbase64.yaml | base64 --decode > oidcConfig.yaml \
    && sudo sed -i '/tls-private-key-file/r oidcConfig.yaml' \
    /etc/kubernetes/manifests/kube-apiserver.yaml"
sleep 60
done
fi
