#### INSTALL KUBEDB OPERATOR ON THE CLUSTER
* Register for an API token with AppsCode
```
curl -d "email=***" -X POST https://license-issuer.appscode.com/register
```
* Upon registration an API token is received via email (mytoken: b89b801a-733c-41ac-a6db-5568a438e1bc)
* For each new cluster or new license, download and run the below script
```
cd $HOME
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/kubedb/get-kubedb-community-edition-license-keys.sh
chmod +x $HOME/get-kubedb-community-edition-license-keys.sh
source get-kubedb-community-edition-license-keys.sh
```
* Install KubeDB on the cluster
```
helm repo add appscode https://charts.appscode.com/stable/
helm repo update
helm install kubedb appscode/kubedb \
  --version v2023.04.10 \
  --namespace kubedb --create-namespace \
  --set kubedb-provisioner.enabled=true \
  --set kubedb-ops-manager.enabled=true \
  --set kubedb-autoscaler.enabled=true \
  --set kubedb-dashboard.enabled=true \
  --set kubedb-schema-manager.enabled=true \
  --set-file global.license=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-kubedb-license-key.txt
```
