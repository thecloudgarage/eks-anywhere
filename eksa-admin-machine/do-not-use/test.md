```
export virtual_machine_root_password=
export vsphere_user=
export vsphere_password=
sudo apt-get update -y
sudo apt-get install git -y
cd $HOME && git clone https://github.com/thecloudgarage/eks-anywhere.git
find $HOME/eks-anywhere/ -name "*.sh" -type f -print0 | xargs -0 chmod +x
cp $HOME/eks-anywhere/cluster-ops/*.sh $HOME/
sed -i '/^EKSA_VSPHERE_/d' ~/.profile
echo "EKSA_VSPHERE_USERNAME=$vsphere_user; export EKSA_VSPHERE_USERNAME" >> ~/.profile
echo "EKSA_VSPHERE_PASSWORD=$vsphere_password; export EKSA_VSPHERE_PASSWORD" >> ~/.profile
sudo adduser --gecos "" --disabled-password image-builder
sudo chpasswd <<<"image-builder:virtual_machine_root_password"
sudo usermod -aG sudo image-builder
touch useradded.txt
sudo apt-get install build-essential procps curl file git zip unzip sshpass jq -y
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo -e "" | sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo usermod -aG docker ubuntu
wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
chmod +x install.sh
#NOTE HOW WE ARE PASSING AN ENTER FOR THE INTERACTIVE PROMPT THAT THE INSTALL SCRIPT GENERATES TO CONFIRM FOR INSTALLATION
sudo echo -ne '\n' | ./install.sh
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#
sleep 20
brew install aws/tap/eks-anywhere
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew install argocd
brew install fluxcd/tap/flux
#
#
sleep 60

```
Switch to image-builder user
```
export vsphere_server=
export vsphere_user=
export vsphere_password=
export vsphere_datastore=
export vsphere_datacenter=
export virtual_machine_root_password=
#
echo $virtual_machine_root_password | sudo -S ls
cd /home/image-builder
echo "GOVC_URL=$vsphere_server; export GOVC_URL" >> ~/.profile
echo "GOVC_USERNAME=$vsphere_user; export GOVC_USERNAME" >> ~/.profile
echo "GOVC_PASSWORD=$vsphere_password; export GOVC_PASSWORD" >> ~/.profile
echo "GOVC_INSECURE=true; export GOVC_INSECURE" >> ~/.profile
echo "GOVC_DATASTORE=$vsphere_datastore; export GOVC_DATASTORE" >> ~/.profile
echo "GOVC_DATACENTER=$vsphere_datacenter; export GOVC_DATACENTER" >> ~/.profile
echo "EKSA_SKIP_VALIDATE_DEPENDENCIES=true; export EKSA_SKIP_VALIDATE_DEPENDENCIES\" >> ~/.profile
git clone https://github.com/thecloudgarage/eks-anywhere.git
find $HOME/eks-anywhere/ -name "*.sh" -type f -print0 | xargs -0 chmod +x
cp $HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/vsphere-connection.json $HOME/vsphere-connection.json
echo $virtual_machine_root_password | sudo -S apt-get update -y
#
#
mkdir -p /home/image-builder/.ssh
sudo mkdir -p /tmp/eks-image-builder-cni
sudo chown -R image-builder:image-builder /tmp/eks-image-builder-cni
sudo apt install jq unzip make python3 python3-setuptools python3-dev python3-pip -y
#
echo -e "\n" sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install python3.9 -y
echo -e "\n" | sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
echo -e "\n" | sudo update-alternatives --config python3
python3 -m pip install --user ansible
sudo snap install yq
echo "packages installed" > /home/image-builder/done.txt
#sudo apt install python3 python3-setuptools python3-dev python3-pip -y
echo "HostKeyAlgorithms +ssh-rsa" >> /home/image-builder/.ssh/config
echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /home/image-builder/.ssh/config
sudo chmod 600 /home/image-builder/.ssh/config
sudo curl -L -o - https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz | sudo tar -C /usr/local/bin -xvzf - govc
export EKSA_RELEASE_VERSION=$(curl -sL https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml | yq ".spec.latestVersion")
export BUNDLE_MANIFEST_URL=$(curl -s https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml | yq ".spec.releases[] | select(.version==\"$EKSA_RELEASE_VERSION\").bundleManifestUrl")
export IMAGEBUILDER_TARBALL_URI=$(curl -s $BUNDLE_MANIFEST_URL | yq ".spec.versionsBundles[0].eksD.imagebuilder.uri")
echo $EKSA_RELEASE_VERSION > /home/image-builder/eksa_release_version.txt
echo $BUNDLE_MANIFEST_URL > /home/image-builder/bundle_manifest_url.txt
echo $IMAGEBUILDER_TARBALL_URI > /home/image-builder/imagebuilder-tarball-uri.txt
sudo curl -s $IMAGEBUILDER_TARBALL_URI | sudo tar xz ./image-builder
sudo cp image-builder /usr/local/bin
#sudo install -m 0755 ./image-builder /usr/local/bin/image-builder
cd -
```
