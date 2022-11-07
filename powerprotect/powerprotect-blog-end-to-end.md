# Kubernetes Data Protection using Dell's PowerProtect Data Manager
## TO BEGIN, let's clear the air by answering some questions that may be lingering in the top-chamber
### :question: I do not have a PowerStore Array that is used in this Example for sockshop data services persistence layer
* No problem, although these scenarios deploy persistent workloads of sock-shop application, the same can be easily swapped with the default storage class on VSAN/VMFS or any other storage CSI. 
* You will need to edit the storage class in the sockshop deployment YAML and in the volumesnapshotclass YAML
* Sockshop deployment YAML is located under the sockshop sub-directory
* volumesnapshotclass YAML is located under the powerprotect sub-directory

### :question: Can I use this procedure with any other Kubernetes distribution
* Absolutely, once you get a comprehension of the PowerProtect Data manager workflows documented here, these can be reused in any Kubernetes distribution of choice (OpenShift, Rancher, AKS, GKE, etc.)

### :question: Can I use a different application example
* Absolutely, as long as one understands the PowerProtect workflows exhibited via sockshop application backup and restore, any cluster scoped or namespaced scoped resources pertaining to any application can be handled

### :question: The example uses PowerProtect as a virtual appliance deployed on premises. Can I deploy PowerProtect in the public cloud
* PowerProtect Data manager itself can be deployed in vSphere as an OVA or as machine images in AWS, GCP, Azure.
* As long as the PowerProtect Data Manager bears IP connectivity to the target Kubernetes cluster/s, the workflows documented herein are absolutely valid

### :question: Is there a possibility to backup the Kubernetes data to public cloud or a compatible object storage
* Absolutely, PowerProtect Data Manager supports cloud disaster recovery and also cloud tiering. One can further explore those use-cases once primary understanding of the workflows is established

# :running: LET'S BEGIN

### :cloud: Scenario-1 Restore a complete namespace within the same EKS Anywhere cluster
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
* Switch kubectl context
```
cd $HOME
source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
```
* Valiate kubectl access
```
kubectl get nodes
```
* :hash: INSTALL POWERSTORE CSI 
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
* DEPLOY METALLB Load Balancer
```
helm upgrade --install --wait --timeout 15m   --namespace metallb-system --create-namespace   --repo https://metallb.github.io/metallb metallb metallb
```
* Deploy IP pools and advertisement CRDs for MetalLB
```
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
* Apply the PowerProtect related RBAC and create snapshot class
```
cd $HOME
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-sa.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-rbac.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-volumesnapshotclass.yaml
```
* Retrive secret token
```
SA_NAME="powerprotect"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep ${SA_NAME} | awk '{print $1}')
```
* Add the c4-eksa1 as an Asset in PPDM-Kubernetes
* Once the discovery if fully complete, create the protection policy for sock-shop namespace and backup
* Delete the sockshop resources
```
kubectl delete deployment carts -n sock-shop
kubectl delete deployment carts-db -n sock-shop
kubectl delete deployment catalogue -n sock-shop
kubectl delete deployment catalogue-db -n sock-shop
kubectl delete deployment front-end -n sock-shop
kubectl delete deployment orders -n sock-shop
kubectl delete deployment orders-db -n sock-shop
kubectl delete deployment payment -n sock-shop
kubectl delete deployment queue-master -n sock-shop
kubectl delete deployment rabbitmq -n sock-shop
kubectl delete deployment session-db -n sock-shop
kubectl delete deployment shipping -n sock-shop
kubectl delete deployment user -n sock-shop
kubectl delete deployment user-db -n sock-shop
kubectl delete ingress ingress-sockshop -n sock-shop
kubectl delete ns sock-shop
```
* If scenario pertains to namespace deletion, recover sock-shop resources via PowerProtect restore and verify
* While restoring select restore to new namespace and provide the same namespace name sock-shop so that powerprotect will create the namespace automatically

### :cloud: SCENARIO-2 Restore from one EKS Anywhere cluster to another EKS Anywhere cluster
* While being SSH'd into EKS Anywhere Administrative machine
* Delete the sock-shop resources
```
kubectl delete deployment carts -n sock-shop
kubectl delete deployment carts-db -n sock-shop
kubectl delete deployment catalogue -n sock-shop
kubectl delete deployment catalogue-db -n sock-shop
kubectl delete deployment front-end -n sock-shop
kubectl delete deployment orders -n sock-shop
kubectl delete deployment orders-db -n sock-shop
kubectl delete deployment payment -n sock-shop
kubectl delete deployment queue-master -n sock-shop
kubectl delete deployment rabbitmq -n sock-shop
kubectl delete deployment session-db -n sock-shop
kubectl delete deployment shipping -n sock-shop
kubectl delete deployment user -n sock-shop
kubectl delete deployment user-db -n sock-shop
kubectl delete ingress ingress-sockshop -n sock-shop
kubectl delete ns sock-shop
```
* DELETE c4-eksa1 cluster
```
cd $HOME
source $HOME/eks-anywhere/cluster-ops/delete-workload-cluster.sh
```
* RECREATE c4-eksa1 cluster
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
* Switch kubectl context
```
cd $HOME
source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
```
* Valiate kubectl access
```
kubectl get nodes
```
* INSTALL POWERSTORE CSI
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
* Install the NGINX Ingress controller
```
cd $HOME
 kubectl apply -f eks-anywhere/sock-shop/ingress-controller-nginx.yaml
```
* Apply the PowerProtect related RBAC and create snapshot class
```
cd $HOME
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-sa.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-rbac.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-volumesnapshotclass.yaml
```
* Retrive secret token
```
SA_NAME="powerprotect"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep ${SA_NAME} | awk '{print $1}')
```
* Edit the credentials defined for c4-eksa1 asset in PPDM
* Edit the c4-eksa1 asset and reverify the certificate
* A discovery will be automatically initiated
* Once the discovery is complete recover the sock-shop application with attributes of original cluster, new namespace (sock-shop)
* Validate sock-shop pods, services and ingress
```
kubectl get pods -n sock-shop
kubectl get services -n sock-shop
kubectl get ingress -n sock-shop
```
* Access the sock-shop application and validate if the demo user and order ID exists
* Create one more order via the same user
