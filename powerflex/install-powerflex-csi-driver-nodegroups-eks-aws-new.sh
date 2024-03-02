#!/bin/bash
echo "Enter Cluster Name on which CSI driver needs to be installed"
read -p 'clusterName: ' clusterName
echo "Enter PowerFlex CSI release version, e.g. 2.6.0"
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
echo "Enter Node Group name on which drivers will be installed, e.g. md-0"
read -p 'nodeSelectorGroupName: ' nodeSelectorGroupName
echo -e "\n"
#export nodeSelectorLabel=group:\ $nodeSelectorGroupName
KUBECONFIG=$HOME/$clusterName/$clusterName-eks-cluster.kubeconfig
mkdir -p $HOME/$clusterName
cd $HOME/$clusterName
#git clone -b v$csiReleaseNumber https://github.com/dell/csi-powerflex.git
#cd $HOME/$clusterName/csi-powerflex
#Added to accomodate higher releases of csi driver installations
#eksdistroversion=$(kubectl get nodes -o=jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')
eksdistroversion=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
export eksdistroversion
#
#INSTALL EXTERNAL SNAPSHOTTER
cd $HOME/$clusterName/
git clone https://github.com/kubernetes-csi/external-snapshotter/
cd ./external-snapshotter
git checkout release-5.0
kubectl kustomize client/config/crd | kubectl create -f -
sed -i "/IfNotPresent$/ a\ \ \ \ \ \ nodeSelector:" deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
sed -i "/nodeSelector:$/ a\ \ \ \ \ \ \ \ group: $nodeSelectorGroupName" deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
kubectl create namespace vxflexos
#
#CREATE POWERFLEX SECRET
cd $HOME/$clusterName
mkdir -p csi-powerflex
cd csi-powerflex
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/secret.yaml
sed -i "s/powerflex_endpoint/$ipOrFqdnOfpowerflexCluster/g" secret.yaml
sed -i "s/powerflex_systemid/$systemIdOfPowerFlexCluster/g" secret.yaml
sed -i "s/powerflex_username/$userNameOfPowerFlexCluster/g" secret.yaml
sed -i "s/powerflex_password/$passwordOfPowerFlexCluster/g" secret.yaml
sed -i "s/powerflex_mdm_ip_addresses/$ipAddressesOfMdmsForPowerFlexCluster/g" secret.yaml
kubectl create secret generic vxflexos-config -n vxflexos --from-file=config=secret.yaml
#
#DOWNLOAD THE HELM CHART FROM DELL REPOSITORY
git clone --quiet -c advice.detachedHead=false -b csi-vxflexos-$csiReleaseNumber https://github.com/dell/helm-charts
#
#REMOVE THE INIT SDC CONTAINER
sed -i '/^ *\initContainers:/{
:sub;
  $b eof;
  N;
/^\( *\)[^ ].*\n\1[^ ][^\n]*$/!b sub;
:eof;
  s/^\( *\)[^ ].*\n\(\1[^ ][^\n]*\)$/\2/;
  t loop;
  d;
:loop; n; b loop;
}' helm-charts/charts/csi-vxflexos/templates/node.yaml
#
#ADD THE NODE-SELECTORS
sed -i "/nodeSelector:$/ a\ \ \ \ group: $nodeSelectorGroupName" helm-charts/charts/csi-vxflexos/values.yaml
#
#MODIFY VOLUME PREFIXES
sed -i "s/k8s/$clusterName/g" helm-charts/charts/csi-vxflexos/values.yaml
#
#MODIFY K8S VERSION IN THE HELM CHART
sed -i "s/^kubeVersion.*/kubeVersion: \"${eksdistroversion}\"/g" helm-charts/charts/csi-vxflexos/Chart.yaml
#
#INSTALL POWERFLEX CSI USING HELM
cd helm-charts/charts
helm install powerflex-csi-450 -n vxflexos csi-vxflexos/ --values csi-vxflexos/values.yaml
#cd $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer
#
#sed -i "s/\/dell\//\/thecloudgarage\//g" csi-install.sh
#sed -i "s/helm-charts/dell-helm-charts/g" csi-install.sh
#
#sed -i '/git$/r'<(
#echo "wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/csi-helper.sh"
#echo "chmod +x csi-helper.sh"
#echo "./csi-helper.sh"
#) csi-install.sh
#
#
#cd $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer
#wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/my-powerflex-settings.yaml
#sed -i "s/csivol/$clusterName-vol/g" my-powerflex-settings.yaml
#sed -i "/nodeSelector:$/ a\ \ \ \ group: $nodeSelectorGroupName" my-powerflex-settings.yaml
#cd $HOME/$clusterName/csi-powerflex/dell-csi-helm-installer
#./csi-install.sh --namespace vxflexos --values ./my-powerflex-settings.yaml --skip-verify --skip-verify-node
cd $HOME/$clusterName/csi-powerflex/
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/powerflex-storage-class.yaml
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/powerflex-volumesnapshotclass.yaml
sed -i "s/powerflexSystemId/$systemIdOfPowerFlexCluster/g" powerflex-storage-class.yaml
kubectl create -f powerflex-storage-class.yaml
kubectl create -f powerflex-volumesnapshotclass.yaml
