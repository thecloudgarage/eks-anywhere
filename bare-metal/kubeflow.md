Deploy Dell PowerScale CSI drivers and Storage Class
```
export csiReleaseNumber=2.10.0
export powerScaleClusterName=F900-AI
export userNameOfPowerScaleCluster=root
export ipOrFqdnOfPowerScaleCluster=172.29.208.91
export passwordOfPowerScaleCluster=XXXXX


eksdistroversion=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
export eksdistroversion

#CLONE THE POWERSCALE CSI REPO
rm -rf csi-powerscale
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
kubectl create -f powerscale-storageclass.yaml

#PATCH STORAGE CLASS AS DEFAULT
kubectl patch storageclass powerscale -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

Install Homebrew
```
wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
chmod +x install.sh
#NOTE HOW WE ARE PASSING AN ENTER FOR THE INTERACTIVE PROMPT THAT THE INSTALL SCRIPT GENERATES TO CONFIRM FOR INSTALLATION
sudo echo -ne '\n' | ./install.sh
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```
Install Kustomize
```
brew install kustomize
git clone https://github.com/kubeflow/manifests.git
cd manifests
while ! kustomize build  example | kubectl apply -f - --server-side --force-conflicts; do echo "Retrying to apply resources"; sleep 10; done
```
Preferably on windows, download and run kubectl
```
https://site-ghwmnxe1v6.talkyard.net/-12/faq-how-to-set-up-kubeconfig-on-windows-wise-paasensaas-k8s-service
```
Launch a notebook with tensorflow image
```
import tensorflow as tf
print("Num GPUs Available: ", len(tf.config.experimental.list_physical_devices('GPU')))
```
