#!/bin/bash
mkdir -p /home/image-builder/.ssh
sudo mkdir -p /tmp/eks-image-builder-cni
sudo chown -R image-builder:image-builder /tmp/eks-image-builder-cni
sudo chmod -R 1777 /tmp
#sudo apt update -y
#sudo snap install yq
sudo apt install jq unzip make ansible -y
sudo apt install python3 python3-setuptools python3-dev python3-pip -y
echo "HostKeyAlgorithms +ssh-rsa" >> /home/$USER/.ssh/config
echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /home/$USER/.ssh/config
cd /tmp
sudo wget https://anywhere-assets.eks.amazonaws.com/releases/bundles/15/artifacts/image-builder/0.1.0/image-builder-linux-amd64.tar.gz
sudo tar -xzf image-builder*.tar.gz
sudo cp image-builder /usr/local/bin
sudo curl -L -o - https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz | sudo tar -C /usr/local/bin -xvzf - govc
exit
