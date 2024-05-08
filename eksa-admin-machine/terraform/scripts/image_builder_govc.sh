#!/bin/bash
mkdir -p /home/image-builder/.ssh
sudo mkdir -p /tmp/eks-image-builder-cni
sudo chown -R image-builder:image-builder /tmp/eks-image-builder-cni
sudo apt install jq unzip make ansible -y
sudo snap install yq -y
sudo apt install python3 python3-setuptools python3-dev python3-pip -y
echo "HostKeyAlgorithms +ssh-rsa" >> /home/image-builder/.ssh/config
echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /home/image-builder/.ssh/config
sudo chmod 600 /home/image-builder/.ssh/config
sudo curl -L -o - https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz | sudo tar -C /usr/local/bin -xvzf - govc
EKSA_RELEASE_VERSION=$(sudo curl -sL https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml | yq ".spec.latestVersion")
BUNDLE_MANIFEST_URL=$(sudo curl -s https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml | yq ".spec.releases[] | select(.version==\"$EKSA_RELEASE_VERSION\").bundleManifestUrl")
IMAGEBUILDER_TARBALL_URI=$(sudo curl -s $BUNDLE_MANIFEST_URL | yq ".spec.versionsBundles[0].eksD.imagebuilder.uri")
echo $IMAGEBUILDER_TARBALL_URI > /home/image-builder/imagebuilder-tarball-uri.txt
curl -s $IMAGEBUILDER_TARBALL_URI | tar xz ./image-builder
sudo cp image-builder /usr/local/bin
#sudo install -m 0755 ./image-builder /usr/local/bin/image-builder
cd -
exit
