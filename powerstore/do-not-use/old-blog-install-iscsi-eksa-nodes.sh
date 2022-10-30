#!bin/bash
read -p 'clusterName: ' clusterName
masterIps=$(kubectl get nodes --selector='node-role.kubernetes.io/master' \
    -o template \
    --template='{{range.items}}{{range.status.addresses}}{{if eq .type "ExternalIP"}}{{.address}}{{end}}{{end}} {{end}}')
workerIps=$(kubectl get nodes --selector='!node-role.kubernetes.io/master' \
    -o template \
    --template='{{range.items}}{{range.status.addresses}}{{if eq .type "ExternalIP"}}{{.address}}{{end}}{{end}} {{end}}')

for masterIp in $masterIps
do
ssh \
    -o StrictHostKeyChecking=no \
    -t \
    -i /home/ubuntu/$clusterName/eks-a-id_rsa \
    capv@$masterIp \
    "sudo  apt-get update -y \
    && sudo apt install open-iscsi -y \
    && sudo systemctl enable --now iscsid"
done

for workerIp in $workerIps
do
ssh \
    -o StrictHostKeyChecking=no \
    -t \
    -i /home/ubuntu/$clusterName/eks-a-id_rsa \
    capv@$workerIp \
    "sudo  apt-get update -y \
    && sudo apt install open-iscsi -y \
    && sudo systemctl enable --now iscsid"
done
