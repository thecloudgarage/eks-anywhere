#!/bin/bash
echo "Input OIDC enabled cluster name for kubectl context"
read -p 'oidClusterName: ' oidcClusterName
echo "Input your OIDC servers FQDN"
read -p 'fqdnOfKeyCloakServer: ' fqdnOfKeyCloakServer
echo "Input your OIDC client id"
read -p 'oidcClientId: ' oidcClientId
echo "Input your OIDC Secret"
read -sp 'oidcClientSecret: ' oidcClientSecret
echo "Input your OIDC Username"
read -p 'oidcUsername: ' oidcUsername
echo "Input your OIDC Password"
read -sp 'oidcPassword: ' oidcPassword
echo "Provide the API server endpoint in the format https://172.24.165.11:6443"
echo "Ensure that https and port number 6443 is mentioned as specififed in the above format"
echo "Only in cases e.g. eks public clusters, you can omit the port number as it provides a load-balancer URL"
read -p 'apiServerEndpoint: ' apiServerEndpoint
kubectl config --kubeconfig=$HOME/.kube/config set-cluster \
$oidcClusterName --server=$apiServerEndpoint --insecure-skip-tls-verify
echo -n | openssl s_client -connect $fqdnOfKeyCloakServer:443 -servername $fqdnOfKeyCloakServer \
    | openssl x509 > $HOME/$fqdnOfKeyCloakServer.crt
ISSUER=https://$fqdnOfKeyCloakServer/auth/realms/master
ENDPOINT=$ISSUER/protocol/openid-connect/token
ID_TOKEN=$(curl -k -X POST $ENDPOINT \
        -d grant_type=password \
        -d client_id=$oidcClientId \
        -d client_secret=$oidcClientSecret \
        -d username=$oidcUsername \
        -d password=$oidcPassword \
        -d scope=openid \
        -d response_type=id_token | jq -r '.id_token')
REFRESH_TOKEN=$(curl -k -X POST $ENDPOINT \
        -d grant_type=password \
        -d client_id=$oidcClientId \
        -d client_secret=$oidcClientId \
        -d username=$oidcUsername \
        -d password=$oidcPassword \
        -d scope=openid \
        -d response_type=id_token | jq -r '.refresh_token')
  kubectl config delete-user $oidcUsername
  kubectl config delete-context $oidcUsername-$oidcClusterName
  kubectl config unset current-context
CA_DATA=$(cat $HOME/$fqdnOfKeyCloakServer.crt | base64 | tr -d '\n')
  kubectl config --kubeconfig=$HOME/.kube/config set-credentials $oidcUsername \
          --auth-provider=oidc \
          --auth-provider-arg=client-id=$oidcClientId \
          --auth-provider-arg=client-secret=$oidcClientSecret \
          --auth-provider-arg=idp-issuer-url=$ISSUER \
          --auth-provider-arg=id-token=$ID_TOKEN \
          --auth-provider-arg=refresh-token=$REFRESH_TOKEN \
          --auth-provider-arg=idp-certificate-authority-data=$CA_DATA
  kubectl config --kubeconfig=$HOME/.kube/config set-context $oidcUsername-$oidcClusterName --cluster=$oidcClusterName --user=$oidcUsername
  kubectl config --kubeconfig=$HOME/.kube/config use-context $oidcUsername-$oidcClusterName
