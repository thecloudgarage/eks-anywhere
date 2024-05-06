#!/bin/bash
mkdir -p /home/image-builder/.ssh
sudo mkdir -p /tmp/eks-image-builder-cni
sudo chown -R image-builder:image-builder /tmp/eks-image-builder-cni
sudo apt install jq unzip make -y
sudo apt install python3 python3-setuptools python3-dev python3-pip -y
echo "HostKeyAlgorithms +ssh-rsa" >> /home/$USER/.ssh/config
echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /home/$USER/.ssh/config
sudo chmod 600 /home/image-builder/.ssh/config
python3 -m pip install --user ansible
curl -L -o - "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz" | sudo tar -C /usr/local/bin -xvzf - govc
exit
