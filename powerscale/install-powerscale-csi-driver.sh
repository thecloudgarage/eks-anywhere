#!/bin/bash
echo "Enter EKSA Cluster Name on which CSI driver needs to be installed"
read -p 'clusterName: ' clusterName
echo "Enter PowerScale CSI release version, e.g. 2.2.0, 2.3.0, 2.4.0, 2.5.0"
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
#CLONE THE POWERSCALE CSI REPO
mkdir -p $HOME/$clusterName
cd $HOME/$clusterName
git clone -b v$csiReleaseNumber https://github.com/dell/csi-powerscale.git
cd $HOME/$clusterName/csi-powerscale
#EXPORT EKS DISTRO VERSION FOR CSI VERIFICATION
eksdistroversion=$(kubectl get nodes -o=jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')
sed -i "s/>= 1.21.0 < 1.26.0/$eksdistroversion/g" helm/csi-isilon/Chart.yaml
cd $HOME/$clusterName/csi-powerscale
#INSTALL EXTERNAL SNAPSHOTTER
git clone https://github.com/kubernetes-csi/external-snapshotter/
cd ./external-snapshotter
git checkout release-5.0
kubectl kustomize client/config/crd | kubectl create -f -
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
#PREPARE FOR POWERSCALE CSI INSTALLATION
kubectl create namespace csi-powerscale
cd $HOME/$clusterName/csi-powerscale/dell-csi-helm-installer
cp $HOME/eks-anywhere/powerscale/powerscale-creds.yaml powerscale-creds.yaml
cp $HOME/eks-anywhere/powerscale/emptysecret.yaml emptysecret.yaml
#BUILD CREDS FILE FOR POWERSCALE CSI
sed -i "s/powerscale_cluster_name/$powerScaleClusterName/g" $HOME/$clusterName/csi-powerscale/dell-csi-helm-installer/powerscale-creds.yaml
sed -i "s/powerscale_username/$userNameOfPowerScaleCluster/g" $HOME/$clusterName/csi-powerscale/dell-csi-helm-installer/powerscale-creds.yaml
sed -i "s/powerscale_password/$passwordOfPowerScaleCluster/g" $HOME/$clusterName/csi-powerscale/dell-csi-helm-installer/powerscale-creds.yaml
sed -i "s/powerscale_endpoint/$ipOrFqdnOfPowerScaleCluster/g" $HOME/$clusterName/csi-powerscale/dell-csi-helm-installer/powerscale-creds.yaml
#CREATE SECRETS FOR POWERSCALE CSI
kubectl create secret generic isilon-creds -n csi-powerscale --from-file=config=powerscale-creds.yaml -o yaml --dry-run=client | kubectl apply -f -
kubectl create -f emptysecret.yaml
#BUILD SETTINGS FILE FOR POWERSCALE CSI
cd $HOME/$clusterName/csi-powerscale/dell-csi-helm-installer/
cp $HOME/$clusterName/csi-powerscale/helm/csi-isilon/values.yaml my-powerscale-settings.yaml
sed -i "s/volumeNamePrefix: k8s/volumeNamePrefix: $clusterName-vol/g" my-powerscale-settings.yaml
sed -i "s/snapNamePrefix: snapshot/snapNamePrefix: $clusterName-snap/g" my-powerscale-settings.yaml
sed -i 's/isiAuthType: 0/isiAuthType: 1/g' my-powerscale-settings.yaml
#INSTALL POWERSCALE CSI
cd $HOME/$clusterName/csi-powerscale/dell-csi-helm-installer
./csi-install.sh --namespace csi-powerscale --values ./my-powerscale-settings.yaml --skip-verify --skip-verify-node
#CREATE STORAGE CLASS FOR POWERSCALE CSI
cd $HOME/$clusterName/csi-powerscale/dell-csi-helm-installer
cp $HOME/eks-anywhere/powerscale/powerscale-storageclass.yaml ./powerscale-storageclass.yaml
kubectl create -f $HOME/$clusterName/csi-powerscale/dell-csi-helm-installer/powerscale-storageclass.yaml
