#!/bin/bash
echo "Enter Cluster Name on which CSI driver needs to be installed"
read -p 'clusterName: ' clusterName
echo "Enter IP or FQDN of the PowerStore array"
read -p 'ipOrFqdnOfPowerStoreArray: ' ipOrFqdnOfPowerStoreArray
echo "Enter Global Id of the PowerStore Array"
read -p 'globalIdOfPowerStoreArray: ' globalIdOfPowerStoreArray
echo "Enter username of the PowerStore Array"
read -p 'userNameOfPowerStoreArray: ' userNameOfPowerStoreArray
echo "Enter password of the PowerStore Array"
read -p 'passwordOfPowerStoreArray: ' passwordOfPowerStoreArray
cd $HOME/$clusterName
git clone -b v2.2.0 https://github.com/dell/csi-powerstore.git 
cd $HOME/$clusterName/csi-powerstore
cp $HOME/eks-anywhere/powerstore/install-iscsi-eksa-nodes.sh .
chmod +x install-iscsi-eksa-nodes.sh
printf "$clusterName\n" | source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
git clone https://github.com/kubernetes-csi/external-snapshotter/
cd ./external-snapshotter
git checkout release-5.0
kubectl kustomize client/config/crd | kubectl create -f -
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
kubectl create namespace csi-powerstore
cd $HOME/$clusterName/csi-powerstore
printf "$clusterName\n" | source install-iscsi-eksa-nodes.sh
cd $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer
cp $HOME/$clusterName/csi-powerstore/samples/secret/secret.yaml secret.yaml 
sed -i "9s/10.0.0.1/$ipOrFqdnOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
sed -i "14s/unique/$globalIdOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
#Note we are using a sed expression to change the exact match of the word user in a particular line
sed -i "19s/\user\b/$userNameOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
#Note we are using a sed expression to change a double quoted string, notice the use of single quotes
sed -i "24s/\(.*\)password/\1$passwordOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
sed -i "48s/auto/iSCSI/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
#Note we are deleting unwanted stuff from the file
sed -i -n -e :a -e '1,27!{P;N;D;};N;ba' $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
kubectl create secret generic powerstore-config -n csi-powerstore --from-file=config=secret.yaml
cd $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer
cp $HOME/$clusterName/csi-powerstore/helm/csi-powerstore/values.yaml my-powerstore-settings.yaml
sed -i "s/csivol/$clusterName-vol/g" my-powerstore-settings.yaml
sed -i "s/csisnap/$clusterName-snap/g" my-powerstore-settings.yaml
sed -i "s/csi-node/eksa-node/g" my-powerstore-settings.yaml 
cd $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer
./csi-install.sh --namespace csi-powerstore --values ./my-powerstore-settings.yaml --skip-verify --skip-verify-node
cd $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer
cp $HOME/$clusterName/csi-powerstore/samples/storageclass/powerstore-ext4.yaml ./powerstore-ext4-iscsi-storage-class.yaml
sed -i "s/Unique/globalIdOfPowerStoreArray/g" $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/powerstore-ext4-iscsi-storage-class.yaml
kubectl create -f $HOME/$clusterName/csi-powerstore/dell-csi-helm-installer/powerstore-ext4-iscsi-storage-class.yaml
