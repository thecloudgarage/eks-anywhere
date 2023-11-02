#!/bin/bash
echo "Enter Cluster Name on which CSI driver needs to be installed"
read -p 'clusterName: ' clusterName
echo "Enter PowerFlex CSI release version, e.g. 2.2.0, 2.3.0, 2.4.0, 2.5.0"
read -p 'csiReleaseNumber: ' csiReleaseNumber
echo "Enter IP or FQDN of the powerflex cluster"
read -p 'ipOrFqdnOfPowerFlexCluster: ' ipOrFqdnOfpowerflexCluster
echo "Enter Comma separated MDM IP addresses for powerflex cluster"
read -p 'ipAddressesOfMdmsForPowerFlexCluster: ' ipAddressesOfMdmsForPowerFlexCluster
echo "Enter System Id of the powerflex cluster"
read -p 'systemIdOfPowerFlexCluster: ' systemIdOfPowerFlexCluster
echo "Enter username of the powerflex cluster"
read -p 'userNameOfPowerFlexCluster: ' userNameOfPowerFlexCluster
echo "Enter password of the powerflex cluster"
read -sp 'passwordOfPowerFlexCluster: ' passwordOfPowerFlexCluster
echo "Enter Node Group name on which drivers will be installed, e.g. md-2"
read -p 'nodeSelectorGroupName: ' nodeSelectorGroupName
echo -e "\n"
printf "$clusterName\n" | source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
source $HOME/.profile
mkdir -p $HOME/$clusterName
cd $HOME/$clusterName
git clone -b v$csiReleaseNumber https://github.com/dell/csi-powerflex.git
cd $HOME/$clusterName/csi-powerflex
#Added to accomodate higher releases of csi driver installations
#eksdistroversion=$(kubectl get nodes -o=jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')
eksdistroversion=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
sed -i "s/>= 1.21.0 < 1.26.0/$eksdistroversion/g" helm/csi-vxflexos/Chart.yaml
cd $HOME/$clusterName/csi-powerflex
git clone https://github.com/kubernetes-csi/external-snapshotter/
cd ./external-snapshotter
git checkout release-5.0
kubectl kustomize client/config/crd | kubectl create -f -
sed -i "/IfNotPresent$/ a\ \ \ \ \ \ nodeSelector:" deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
sed -i "/nodeSelector:$/ a\ \ \ \ \ \ \ \ group: $nodeSelectorGroupName" deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
kubectl create namespace vxflexos
cd $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/secret.yaml
sed -i "s/powerflex_endpoint/$ipOrFqdnOfpowerflexCluster/g" $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer/secret.yaml
sed -i "s/powerflex_systemid/$systemIdOfPowerFlexCluster/g" $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer/secret.yaml
sed -i "s/powerflex_username/$userNameOfPowerFlexCluster/g" $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer/secret.yaml
sed -i "s/powerflex_password/$passwordOfPowerFlexCluster/g" $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer/secret.yaml
sed -i "s/powerflex_mdm_ip_addresses/$ipAddressesOfMdmsForPowerFlexCluster/g" $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer/secret.yaml
kubectl create secret generic vxflexos-config -n vxflexos --from-file=config=secret.yaml
cd $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/my-powerflex-settings.yaml
sed -i "s/csivol/$clusterName-vol/g" my-powerflex-settings.yaml
sed -i "/nodeSelector:$/ a\ \ \ \ group: $nodeSelectorGroupName" my-powerflex-settings.yaml
cd $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer
./csi-install.sh --namespace vxflexos --values ./my-powerflex-settings.yaml --skip-verify --skip-verify-node
cd $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/powerflex-storage-class.yaml
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/powerflex-volumesnapshotclass.yaml
sed -i "s/powerflexSystemId/$systemIdOfPowerFlexCluster/g" $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer/powerflex-storage-class.yaml
kubectl create -f $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer/powerflex-storage-class.yaml
kubectl create -f $HOME/eks-anywhere/powerflex/powerflex-volumesnapshotclass.yaml
