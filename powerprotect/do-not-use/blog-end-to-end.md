# SCENARIO-1
* SSH into EKS Anywhere Administrative machine
* CREATE c4-eksa1 cluster
```
CLUSTER_NAME=c4-eksa1
API_SERVER_IP=172.24.165.11
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
eksctl anywhere create cluster -f $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
```
* Validate cluster is installed
```
cd $HOME
source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
kubectl get nodes
```
* INSTALL POWERSTORE CSI ON c4-eksa1
```
source eks-anywhere/powerstore/install-powerstore-csi-driver.sh
clusterName: c4-eksa1              
Enter IP or FQDN of the PowerStore array
ipOrFqdnOfPowerStoreArray: 172.24.185.106
Enter Global Id of the PowerStore Array
globalIdOfPowerStoreArray: PS4ebb8d4e8488 
Enter username of the PowerStore Array
userNameOfPowerStoreArray: iac
Enter password of the PowerStore Array
passwordOfPowerStoreArray:
```
* DEPLOY METALLB Load Balancer along with IP advertisement CRDs
```
helm upgrade --install --wait --timeout 15m   --namespace metallb-system --create-namespace   --repo https://metallb.github.io/metallb metallb metallb

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.24.165.21-172.24.165.25
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF
```
* DEPLOY SOCK-SHOP
```
cd ~/eks-anywhere/sock-shop
source deploy-sockshop.sh
```
* Validate sock-shop pods, services and ingress
```
kubectl get pods -n sock-shop
kubectl get services -n sock-shop
kubectl get ingress -n sock-shop
```
* Edit local host file or add DNS entry
```
sockshop.thecloudgarage.com 172.24.165.21
```
* Access sock-shop and create a demo user along with a sample order
* Apply the PowerProtect RBAC and retrieve Service account token
```
cd $HOME
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect.yaml
SA_NAME="powerprotect"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep ${SA_NAME} | awk '{print $1}')
```
* Delete the namespace and recover the namespace

# SCENARIO-2
* While being SSH'd into EKS Anywhere Administrative machine
* DELETE c4-eksa1 cluster
* CREATE c4-eksa2 cluster
```
CLUSTER_NAME=c4-eksa2
API_SERVER_IP=172.24.165.11
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
eksctl anywhere create cluster -f $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
```
* Validate cluster is installed
```
cd $HOME
source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
kubectl get nodes
```
* INSTALL POWERSTORE CSI ON c4-eksa1
```
source eks-anywhere/powerstore/install-powerstore-csi-driver.sh
clusterName: c4-eksa2              
Enter IP or FQDN of the PowerStore array
ipOrFqdnOfPowerStoreArray: 172.24.185.106
Enter Global Id of the PowerStore Array
globalIdOfPowerStoreArray: PS4ebb8d4e8488 
Enter username of the PowerStore Array
userNameOfPowerStoreArray: iac
Enter password of the PowerStore Array
passwordOfPowerStoreArray:
```
* DEPLOY METALLB Load Balancer along with IP advertisement CRDs
```
helm upgrade --install --wait --timeout 15m   --namespace metallb-system --create-namespace   --repo https://metallb.github.io/metallb metallb metallb

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.24.165.21-172.24.165.25
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF
```
* Apply the PowerProtect RBAC and retrieve Service account token
```
cd $HOME
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect.yaml
SA_NAME="powerprotect"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep ${SA_NAME} | awk '{print $1}')
```
* Create an empty namespace for sockshop for recovery
```
kubectl create ns sock-shop
```
* Discover the c4-eksa2 cluster in PowerProtect and recover the sock-shop application
* Validate sock-shop pods, services and ingress
```
kubectl get pods -n sock-shop
kubectl get services -n sock-shop
kubectl get ingress -n sock-shop
```
* Access the sock-shop application and validate if the demo user and order ID exists
* Create one more order via the same user



