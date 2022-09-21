#!/bin/bash
sudo adduser --gecos "" --disabled-password image-builder
sudo chpasswd <<<"image-builder:virtual_machine_root_password"
sudo usermod -aG sudo image-builder
sudo mkdir -p /tmp/eks-image-builder-cni
sudo chown -R image-builder:image-builder /tmp/eks-image-builder-cni
touch useradded.txt
sudo apt-get install build-essential procps curl file git zip unzip sshpass jq -y
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo usermod -aG docker ubuntu
# Uncomment below if challenged with Homebrew installation
#git config --global --unset http.proxy
#git config --global --unset https.proxy
wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
chmod +x install.sh
#NOTE HOW WE ARE PASSING AN ENTER FOR THE INTERACTIVE PROMPT THAT THE INSTALL SCRIPT GENERATES TO CONFIRM FOR INSTALLATION
sudo echo -ne '\n' | ./install.sh
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
exit
