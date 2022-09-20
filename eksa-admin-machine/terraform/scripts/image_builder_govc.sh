#!/bin/bash
sudo apt install jq unzip make ansible -y
sudo apt install python3-pip -y
sudo snap install yq
mkdir -p /home/image-builder/.ssh
cd /tmp
sudo wget https://anywhere-assets.eks.amazonaws.com/releases/bundles/15/artifacts/image-builder/0.1.0/image-builder-linux-amd64.tar.gz
sudo tar -xzf image-builder*.tar.gz
sudo cp image-builder /usr/local/bin
sudo curl -L -o - https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz | sudo tar -C /usr/local/bin -xvzf - govc
exit
