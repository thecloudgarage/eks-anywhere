Generate keys for EKS cluster
```
ssh-keygen
```
Deploy EKS cluster
```
cd $HOME
CLUSTER_NAME=eks-aws-1
mkdir -p $HOME/$CLUSTER_NAME
cd $HOME/$CLUSTER_NAME
cp $HOME/.ssh/id_rsa ~/eks
cp $HOME/.ssh/id_rsa.pub ~/eks.pub
cp $HOME/eks-anywhere/eks-aws/eks-spot.yaml $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
sed -i "s/ekstest/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY eksctl create cluster -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml --kubeconfig=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
KUBECONFIG=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
```
Apply EBS CSI driver IAM policy for the EKS cluster IAM role
Deploy EBS CSI drivers along with storage class, snapshot class and powerprotect sa plus rbac
```
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
kubectl apply -f $HOME/eks-anywhere/eks-aws/ebs-sc.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/examples/kubernetes/snapshot/manifests/classes/snapshotclass.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
kubectl patch storageclass gp2 -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}" 
kubectl patch storageclass ebs-sc -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}" 
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-sa.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-rbac.yaml
```
Deploy sock-shop on AWS EKS
```
cd $HOME
source eks-anywhere/sock-shop/deploy-sockshop-aws-eks.sh
```
Get the ingress NLB url
```
kubectl get ingress -n sock-shop
```
Update the hosts file with NLB IP (not url)
Access sock-shop application and create users/orders
Retrieve PowerProtect SA token
```
SA_NAME="powerprotect"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep ${SA_NAME} | awk '{print $1}')
```
Discover the EKS cluster in PPDM
Create the backup policy
Backup the state of sock-shop application
Deploy EKS Anywhere cluster with add-ons
```
source create-eksa-with-addons.sh
```
Deploy powerprotect sa plus rbac
```
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-sa.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-rbac.yaml
```
Discover the EKS Anywhere cluster in PPDM
Initiate a restore of the sock-shop asset
