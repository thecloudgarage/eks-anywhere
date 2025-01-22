#!/bin/bash
mkdir -p /home/image-builder/.ssh
sudo mkdir -p /tmp/eks-image-builder-cni
sudo chown -R image-builder:image-builder /tmp/eks-image-builder-cni
sudo apt install jq unzip make python3 python3-setuptools python3-dev python3-pip -y
#
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install python3.9 -y
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
sudo update-alternatives --config python3
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
exit
