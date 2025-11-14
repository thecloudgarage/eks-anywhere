#!/bin/bash
echo "Enter EKSA Cluster Name on which CSI driver needs to be installed"
read -p 'clusterName: ' clusterName
echo "Enter PowerScale CSI release version, e.g. 2.7.0, 2.8.0, 2.9.0, 2.9.1, 2.10.0"
read -p 'csiReleaseNumber: ' csiReleaseNumber
echo "Enter PowerScale Cluster Name"
read -p 'powerScaleClusterName: ' powerScaleClusterName
echo "Enter IP or FQDN of the PowerStore array"
read -p 'ipOrFqdnOfPowerStoreArray: ' ipOrFqdnOfPowerScaleCluster
echo "Enter username of PowerScale Cluster"
read -p 'userNameOfPowerScaleCluster: ' userNameOfPowerScaleCluster
echo "Enter password of the PowerScale Cluster"
read -sp 'passwordOfPowerScaleCluster: ' passwordOfPowerScaleCluster
echo -e "\n"
#SET KUBECTL CONTEXT
printf "$clusterName\n" | source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
source $HOME/.profile
#
KUBECONFIG=$HOME/$clusterName/$clusterName-eks-a-cluster.kubeconfig
mkdir -p $HOME/$clusterName
cd $HOME/$clusterName
#
eksdistroversion=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
export eksdistroversion
#
#INSTALL EXTERNAL SNAPSHOTTER
git clone https://github.com/kubernetes-csi/external-snapshotter/
cd ./external-snapshotter
git checkout release-5.0
kubectl kustomize client/config/crd | kubectl create -f -
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
#CLONE THE POWERSCALE CSI REPO
cd $HOME/$clusterName
mkdir -p csi-powerscale
cd csi-powerscale
git clone --quiet -c advice.detachedHead=false -b csi-isilon-$csiReleaseNumber https://github.com/dell/helm-charts
#MODIFY VOLUME PREFIXES
sed -i "s/^volumeNamePrefix:.*/volumeNamePrefix:\ $clusterName/g" helm-charts/charts/csi-isilon/values.yaml
sed -i "s/snapNamePrefix: snapshot/snapNamePrefix: $clusterName-snap/g" helm-charts/charts/csi-isilon/values.yaml
sed -i 's/isiAuthType: 0/isiAuthType: 1/g' helm-charts/charts/csi-isilon/values.yaml
#MODIFY K8S VERSION IN THE HELM CHART TO CUSTOM VALUE USED BY EKS DISTRO
sed -i "s/^kubeVersion.*/kubeVersion: \"${eksdistroversion}\"/g" helm-charts/charts/csi-isilon/Chart.yaml
#PREPARE FOR POWERSCALE CSI INSTALLATION
kubectl create namespace csi-powerscale
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerscale/powerscale-creds.yaml
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerscale/emptysecret.yaml
#BUILD CREDS FILE FOR POWERSCALE CSI
sed -i "s/powerscale_cluster_name/$powerScaleClusterName/g" powerscale-creds.yaml
sed -i "s/powerscale_username/$userNameOfPowerScaleCluster/g" powerscale-creds.yaml
sed -i "s/powerscale_password/$passwordOfPowerScaleCluster/g" powerscale-creds.yaml
sed -i "s/powerscale_endpoint/$ipOrFqdnOfPowerScaleCluster/g" powerscale-creds.yaml
#CREATE SECRETS FOR POWERSCALE CSI
kubectl create secret generic isilon-creds -n csi-powerscale --from-file=config=powerscale-creds.yaml -o yaml --dry-run=client | kubectl apply -f -
kubectl create -f emptysecret.yaml
#INSTALL POWERSCALE CSI
cd helm-charts/charts
helm install isilon -n csi-powerscale csi-isilon/ --values csi-isilon/values.yaml
#CREATE STORAGE CLASS FOR POWERSCALE CSI
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerscale/powerscale-storageclass.yaml
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerscale/powerscale-volumesnapshotclass.yaml
kubectl create -f powerscale-storageclass.yaml
kubectl create -f powerscale-volumesnapshotclass.yaml
