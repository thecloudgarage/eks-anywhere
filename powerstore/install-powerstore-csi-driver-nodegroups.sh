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
echo "Enter Node Group name on which drivers will be installed, e.g. md-2"
read -p 'nodeSelectorGroupName: ' nodeSelectorGroupName
echo -e "\n"
printf "$clusterName\n" | source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
source $HOME/.profile
mkdir -p $HOME/$clusterName
cd $HOME/$clusterName
git clone -b v$csiReleaseNumber https://github.com/dell/csi-powerstore.git
cd $HOME/$clusterName/csi-powerstore
#Added to accomodate higher releases of csi driver installations
eksdistroversion=$(kubectl get nodes -o=jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')
sed -i "s/>= 1.21.0 < 1.26.0/$eksdistroversion/g" helm/csi-powerstore/Chart.yaml
cd $HOME/$clusterName/csi-powerstore
git clone https://github.com/kubernetes-csi/external-snapshotter/
cd ./external-snapshotter
git checkout release-5.0
kubectl kustomize client/config/crd | kubectl create -f -
sed -i "/IfNotPresent$/ a\ \ \ \ \ \ nodeSelector:" deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
sed -i "/nodeSelector:$/ a\ \ \ \ \ \ \ \ group: $nodeSelectorGroupName" deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
kubectl create namespace csi-powerstore
cd $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer
cp $HOME/eks-anywhere/powerstore/secret.yaml secret.yaml
sed -i "s/powerstore_endpoint/$ipOrFqdnOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
sed -i "s/powerstore_globalid/$globalIdOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
sed -i "s/powerstore_username/$userNameOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
sed -i "s/powerstore_password/$passwordOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
kubectl create secret generic powerstore-config -n csi-powerstore --from-file=config=secret.yaml
cd $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer
cp $HOME/$clusterName/csi-powerstore/helm/csi-powerstore/values.yaml my-powerstore-settings.yaml
sed -i "s/csivol/$clusterName-vol/g" my-powerstore-settings.yaml
sed -i "s/csisnap/$clusterName-snap/g" my-powerstore-settings.yaml
sed -i "s/csi-node/eksa-node/g" my-powerstore-settings.yaml
sed -i "/nodeSelector:$/ a\ \ \ \ group: $nodeSelectorGroupName" my-powerstore-settings.yaml
cd $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer
./csi-install.sh --namespace csi-powerstore --values ./my-powerstore-settings.yaml --skip-verify --skip-verify-node
cd $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer
cp $HOME/$clusterName/csi-powerstore/samples/storageclass/powerstore-topology.yaml ./powerstore-ext4-iscsi-storage-class.yaml
sed -i "s/Unique/$globalIdOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/powerstore-ext4-iscsi-storage-class.yaml
sed -i "s/12.34.56.78/$ipOrFqdnOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/powerstore-ext4-iscsi-storage-class.yaml
kubectl create -f $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/powerstore-ext4-iscsi-storage-class.yaml
kubectl create -f $HOME/eks-anywhere/powerstore/powerstore-ext4-iscsi-snap-class.yaml
