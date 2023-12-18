Perform this action One time
```
curl -d "email=***" -X POST https://license-issuer.appscode.com/register
```
You will receive an email with the API token

### For each new cluster or new license, run the below script. 
The script will automatically generate the Community edition (1 year eval) license keys and place it within the EKS Anywhere cluster directory. 
```
cd $HOME
rm -rf get-kubedb-enterprise-edition-license-keys.sh
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/kubedb/get-kubedb-enterprise-edition-license-keys.sh
chmod +x $HOME/get-kubedb-enterprise-edition-license-keys.sh
source get-kubedb-enterprise-edition-license-keys.sh
```
If an Enterprise evaluation license (30 days trial) is required, the run the below script
```
cd $HOME
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/kubedb/get-kubedb-community-edition-license-keys.sh
chmod +x $HOME/get-kubedb-community-edition-license-keys.sh
source get-kubedb-community-edition-license-keys.sh
```
### Add the helm repo
```
helm repo add appscode https://charts.appscode.com/stable/
helm repo update
```
### Install KubeDB community edition on the cluster
```
helm repo add appscode https://charts.appscode.com/stable/
helm repo update
helm install kubedb appscode/kubedb \
  --version v2023.04.10 \
  --namespace kubedb --create-namespace \
  --set-file global.license=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-kubedb-license-key.txt
```
### Install KubeDB enterprise edition on the cluster
```
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
Now that KubeDB is setup, we can start creating DBaaS for various use cases
