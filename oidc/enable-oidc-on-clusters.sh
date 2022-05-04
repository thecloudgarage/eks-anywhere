#!bin/bash
HOSTS=$(kubectl get nodes --selector='node-role.kubernetes.io/master' \
    -o template \
    --template='{{range.items}}{{range.status.addresses}}{{if eq .type "ExternalIP"}}{{.address}}{{end}}{{end}} {{end}}')
keycloakCert=$(cat /home/ubuntu/eks-anywhere/oidc/tls.crt | base64 -w 0)
oidcConfig=$(cat /home/ubuntu/eks-anywhere/oidc/oidc-config.yaml | base64 -w 0)
read -p 'clusterName: ' clusterName
#read -p 'nodeIp: ' nodeIp
for HOST in $HOSTS
do
ssh \
    -o StrictHostKeyChecking=no \
    -t \
    -i /home/ubuntu/$clusterName/eks-a-id_rsa \
    capv@$HOST \
    "sudo echo $keycloakCert > keycloakbase64.crt && cat keycloakbase64.crt | base64 --decode > keycloak.crt \
    && sudo cp keycloak.crt /usr/local/share/ca-certificates && sudo update-ca-certificates \
    && sudo echo $oidcConfig > oidcConfigbase64.yaml && cat oidcConfigbase64.yaml | base64 --decode > oidcConfig.yaml \
    && sudo sed -i '/tls-private-key-file/r oidcConfig.yaml' \
    /etc/kubernetes/manifests/kube-apiserver.yaml"
done
