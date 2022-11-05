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
* INSTALL POWERSTORE CSI 
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
* Recreate an empty namespace
```
kubectl create ns sock-shop
```
* Recover sock-shop resources via PowerProtect restore and verify

# SCENARIO-2
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

# SCENARIO-3
* SSH into the EKS Anywhere Administrative machine
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
* Delete the c4-eksa2 cluster
```
cd $HOME
source $HOME/eks-anywhere/cluster-ops/delete-workload-cluster.sh
```
* Export AWS credentials on the EKS Anywhere Administrative machine for eksctl to create the cluster
```
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export AWS_DEFAULT_REGION=us-east-2
```
* Create EKS cluster c4-eks-aws-1 on AWS public cloud in the above specified region
```
cd $HOME
EKS_CLUSTER_NAME=ebstest
mkdir -p $EKS_CLUSTER_NAME
eksctl create cluster --name $EKS_CLUSTER_NAME --kubeconfig=$HOME/$EKS_CLUSTER_NAME/$EKS_CLUSTER_NAME-eks-cluster.kubeconfig
```
* The EKS cluster c4-eks-aws-1 will take almost 20 minutes to be fully created. Once done.
```
KUBECONFIG=$HOME/$EKS_CLUSTER_NAME/$EKS_CLUSTER_NAME-eks-cluster.kubeconfig
kubectl get nodes
```
* Create EBS storage class on EKS cluster
* Login to AWS console
* Create an IAM policy with the following permissions as shown below and name it as Amazon_EBS_CSI_Driver
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume"
      ],
      "Resource": "*"
    }
  ]
}
```
* Get Worker node IAM Role ARN
```
kubectl -n kube-system describe configmap aws-auth
```
* example from output check rolearn: arn:aws:iam::180789647333:role/eksctl-eksdemo1-nodegroup-eksdemo-NodeInstanceRole-IJN07ZKXAWNN
* Go to Services -> IAM -> Roles - Search for role with name c4-eks-aws-1. There should be a IAM role of that name with nodegroup association. Open it - Click on Permissions tab - Click on Attach Policies - Search for Amazon_EBS_CSI_Driver and click on Attach Policy
* Deploy EBS CSI Driver
```
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
```
* Verify ebs-csi pods running
```
kubectl get pods -n kube-system
```
* Create the EBS storage class
```
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  csi.storage.k8s.io/fstype: xfs
  type: io1
  iopsPerGB: "50"
  encrypted: "true"
EOF
```
* Perform the below scripted additional steps to deploy external-snapshotter and other custom resources
```
cd $HOME
cat <<EOF > $HOME/ebs-extra-steps.sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/examples/kubernetes/snapshot/manifests/classes/snapshotclass.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
kubectl patch storageclass gp2 -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}" 
kubectl patch storageclass ebs-sc -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}" 
EOF
chmod +x $HOME/ebs-extra-steps.sh
./ebs-extra-steps.sh
```
* Deploy NGINX Ingress controller with NLB annotations
```
kubectl apply -f $HOME/eks-anywhere/eks-aws/eks-nlb-nginx-ingress-controller.yaml
```
* Apply the PowerProtect RBAC on the EKS cluster and retrieve Service account token
```
cd $HOME
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect.yaml
SA_NAME="powerprotect"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep ${SA_NAME} | awk '{print $1}')
```
* Retrieve the SSL certificate of the EKS cluster API end point from AWS console
* Decode the Base64 certificate value https://www.base64decode.org/
* SSH into PowerProtect virtual machine as a OS admin user 
* Create a file named c4-eks-aws-1.pem
* Paste the contents of the decoded certificate
* Use the below command to import the eks certificate into powerprotect
```
ppdmtool -i -a c4-eks-aws-1 -f $HOME/c4-eks-aws-1.pem -t PEM
```
* Create an empty namespace for sockshop for recovery
```
kubectl create ns sock-shop
```
* Discover the c4-eks-aws-1 cluster in PowerProtect and recover the sock-shop application
* Validate sock-shop pods, services and ingress
```
kubectl get pods -n sock-shop
kubectl get services -n sock-shop
kubectl get ingress -n sock-shop
```
* Edit the hosts file or DNS entry to route sockshop url to the NLB FQDN
* Access the sock-shop application and validate if the demo user and 2 order IDs exists
* Create one more order via the same user

# SCENARIO-4
* SSH into the EKS Anywhere Administrative machine
* Delete the EKS cluster c4-eks-aws-1 on AWS public cloud
* Before deleting the cluster, ensure that the CSI driver gets uninstalled & the associated IAM policy is deleted from the IAM role, else it might lead to cluster deletion error
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
kubectl delete sc ebs-sc
```
** Go to Services -> IAM -> Roles - Search for role with name c4-eks-aws-1. There should be a IAM role of that name with nodegroup association. Open it - Click on Permissions tab - Click on Attach Policies - Search for Amazon_EBS_CSI_Driver and click on Attach Policy
** Delete the EBS CSI driver
```
kubectl delete -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
```
* CREATE c4-eksa3 cluster
```
CLUSTER_NAME=c4-eksa3
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
* INSTALL POWERSTORE CSI
```
source eks-anywhere/powerstore/install-powerstore-csi-driver.sh
clusterName: c4-eksa3              
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
* Discover the c4-eksa3 cluster in PowerProtect and recover the sock-shop application
* Validate sock-shop pods, services and ingress
```
kubectl get pods -n sock-shop
kubectl get services -n sock-shop
kubectl get ingress -n sock-shop
```
* Access the sock-shop application and validate if the demo user and 3 order IDs exists
* Create one more order via the same user
