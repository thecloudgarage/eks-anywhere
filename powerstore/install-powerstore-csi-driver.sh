#!/bin/bash
echo "Enter Cluster Name on which CSI driver needs to be installed"
read -p 'clusterName: ' clusterName
echo "Enter PowerStore CSI release version, e.g. 2.2.0, 2.3.0, 2.4.0, 2.5.0"
read -p 'csiReleaseNumber: ' csiReleaseNumber
echo "Enter IP or FQDN of the PowerStore array"
read -p 'ipOrFqdnOfPowerStoreArray: ' ipOrFqdnOfPowerStoreArray
echo "Enter Global Id of the PowerStore Array"
read -p 'globalIdOfPowerStoreArray: ' globalIdOfPowerStoreArray
echo "Enter username of the PowerStore Array"
read -p 'userNameOfPowerStoreArray: ' userNameOfPowerStoreArray
echo "Enter password of the PowerStore Array"
read -sp 'passwordOfPowerStoreArray: ' passwordOfPowerStoreArray
echo -e "\n"
printf "$clusterName\n" | source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
source $HOME/.profile
mkdir -p $HOME/$clusterName
eksdistroversion=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
export eksdistroversion
#
#INSTALL EXTERNAL SNAPSHOTTER
git clone https://github.com/kubernetes-csi/external-snapshotter/
cd ./external-snapshotter
git checkout release-5.0
kubectl kustomize client/config/crd | kubectl create -f -
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
#
#CLONE THE POWERSCALE CSI REPO
cd $HOME/$clusterName
mkdir -p csi-powerstore
cd csi-powerstore
git clone --quiet -c advice.detachedHead=false -b csi-powerstore-$csiReleaseNumber https://github.com/dell/helm-charts
#
#MODIFY K8S VERSION IN THE HELM CHART TO CUSTOM VALUE USED BY EKS DISTRO
sed -i "s/^kubeVersion.*/kubeVersion: \"${eksdistroversion}\"/g" helm-charts/charts/csi-powerstore/Chart.yaml
#
#PREPARE FOR POWERSTORE CSI INSTALLATION
kubectl create namespace csi-powerstore
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/refs/heads/main/powerstore/powerstore-creds.yaml
#
#BUILD CREDS FILE FOR POWERSCALE CSI
sed -i "s/powerstore_endpoint/$ipOrFqdnOfPowerStoreArray/g" powerstore-creds.yaml
sed -i "s/powerstore_globalid/$globalIdOfPowerStoreArray/g" powerstore-creds.yaml
sed -i "s/powerstore_username/$userNameOfPowerStoreArray/g" powerstore-creds.yaml
sed -i "s/powerstore_password/$passwordOfPowerStoreArray/g" powerstore-creds.yaml
#
#CREATE SECRETS FOR POWERSCALE CSI
kubectl create secret generic powerstore-config -n csi-powerstore --from-file=config=powerstore-creds.yaml
#
#INSTALL POWERSCALE CSI
cd helm-charts/charts
helm install powerstore -n csi-powerstore csi-powerstore/ --values csi-powerstore/values.yaml
#
#CREATE STORAGE CLASS FOR POWERSCALE CSI
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/refs/heads/main/powerstore/powerstore-ext4-iscsi-storage-class.yaml
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/refs/heads/main/powerstore/powerstore-ext4-iscsi-snap-class.yaml
sed -i "s/Unique/$globalIdOfPowerStoreArray/g" powerstore-ext4-iscsi-topology-storage-class.yaml
kubectl create -f powerstore-ext4-iscsi-topology-storage-class.yaml
kubectl create -f powerstore-ext4-iscsi-snap-class.yaml
