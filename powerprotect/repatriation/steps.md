### Generate keys for EKS cluster
```
ssh-keygen
```
### Deploy EKS cluster
```
cd $HOME
CLUSTER_NAME=c4-aws-1
mkdir -p $HOME/$CLUSTER_NAME
cd $HOME/$CLUSTER_NAME
cp $HOME/.ssh/id_rsa ~/eks
cp $HOME/.ssh/id_rsa.pub ~/eks.pub
cp $HOME/eks-anywhere/eks-aws/eks-on-demand.yaml $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
sed -i "s/ekstest/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY eksctl create cluster -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml --kubeconfig=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
KUBECONFIG=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
```
## 🔴 CAUTION: DO NOT PROCEED WITHOUT APPLYING EBS CSI DRIVER TO THE IAM NODE ROLE
* Deploy EBS CSI drivers along with storage class, snapshot class and powerprotect sa plus rbac
```
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
kubectl apply -f $HOME/eks-anywhere/eks-aws/ebs-sc.yaml
```
## 🔴 CAUTION: WAIT TILL EBS CSI PODS ARE RUNNING
Apply the below YAML to deploy storage class and volume snapshot class along with external snapshotter
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/examples/kubernetes/snapshot/manifests/classes/snapshotclass.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
kubectl patch storageclass gp2 -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}" 
kubectl patch storageclass ebs-sc -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}" 
```
## Apply PowerProtect SA/RBAC configurations
```
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-sa.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-rbac.yaml
```
## Deploy sock-shop on AWS EKS
```
cd $HOME
source eks-anywhere/sock-shop/deploy-sockshop-aws-eks.sh
```
## Get the ingress NLB url
```
kubectl get ingress -n sock-shop
```
* Update the hosts file with NLB IP (not url)
* Access sock-shop application and create users/orders

## Integrate EKS cluster with PowerProtect Data Manager
* Generate SA token
```
SA_NAME="powerprotect"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep ${SA_NAME} | awk '{print $1}')
```
* Discover the EKS cluster in PPDM
* Create the backup policy
* Backup the state of sock-shop application

## Deploy EKS Anywhere cluster with add-ons
```
cd $HOME
source create-eksa-with-addons.sh
```
## Integrate EKS Anywhere cluster with PowerProtect Data Manager
```
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-sa.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-rbac.yaml
```
* Retrieve the token
```
SA_NAME="powerprotect"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep ${SA_NAME} | awk '{print $1}')
```
* Discover the EKS Anywhere cluster in PPDM
* Initiate a restore of the sock-shop asset

# Delete the stack
## Delete sock-shop
```
cd $HOME
source $HOME/eks-anywhere/sock-shop/delete-sockshop-aws.sh
```
## Delete storage class
```
kubectl delete sc ebs-sc
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/examples/kubernetes/snapshot/manifests/classes/snapshotclass.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
```
## Delete EBS CSI driver
```
kubectl delete -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
```
## 🔴 CAUTION: Do not proceed without detatching IAM policy
Go to AWS console and detatch the EBS CSI Driver policy from the Node IAM role

## Delete the EKS cluster
```
cd $HOME/$CLUSTER_NAME
eksctl delete cluster -f $CLUSTER_NAME.yaml
```

