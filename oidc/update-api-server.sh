#!bin/bash
keycloakCert=$(cat /home/ubuntu/kube-oidc/tls.crt | base64 -w 0)
read -p 'clusterName: ' clusterName
read -p 'nodeIp: ' nodeIp
ssh \
    -o StrictHostKeyChecking=no \
    -t \
    -i /home/ubuntu/$clusterName/eks-a-id_rsa \
    capv@$nodeIp \
    "sudo echo $keycloakCert > keycloakbase64.crt && cat keycloakbase64.crt | base64 --decode > keycloak.crt \
    && sudo cp keycloak.crt /usr/local/share/ca-certificates && sudo update-ca-certificates \
    && sudo sed -i '/oidc-username/ a\ \ \ \ \- --oidc-ca-file=/usr/local/share/ca-certificates/keycloak.crt' \
    /etc/kubernetes/manifests/kube-apiserver.yaml"
