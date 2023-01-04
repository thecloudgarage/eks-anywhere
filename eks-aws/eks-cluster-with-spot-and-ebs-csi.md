# Create an EKS cluster with Spot instances and EBS CSI driver
### SSH into the EKS-A Administrative machine and run the below commands
* Please replace the AWS access key id and value along with the intended cluster name
* Change the Region, VPC-ID and Subnet IDs in the eks-spot.yaml located under $HOME/eks-anywhere/eks-aws directory before executing the below commands
```
ssh-keygen
cd $HOME
export AWS_ACCESS_KEY_ID=<insert-key-id>
export AWS_SECRET_ACCESS_KEY=<insert-key-value>
CLUSTER_NAME=c4-eks-aws-1
mkdir -p $HOME/$CLUSTER_NAME
cd $HOME/$CLUSTER_NAME
cp $HOME/.ssh/id_rsa ~/eks
cp $HOME/.ssh/id_rsa.pub ~/eks.pub
cp $HOME/eks-anywhere/eks-aws/eks-spot.yaml $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
sed -i "s/ekstest/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY eksctl create cluster -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml --kubeconfig=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
KUBECONFIG=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
```
* Once the cluster is created switch the kubectl context and verify
```
KUBECONFIG=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
kubectl get nodes
```
### Deploy EBS CSI driver
* Go to AWS Console > Services -> IAM
* Create a Policy named Amazon_EBS_CSI_Driver
* Select JSON tab and copy paste the below JSON
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
* Next get the associated IAM role with the cluster
```
kubectl -n kube-system describe configmap aws-auth
```
* Go to Services -> IAM -> Roles - Search for role with name from the above output and open it - Click on Permissions tab - Click on Attach Policies - Search for Amazon_EBS_CSI_Driver and click on Attach Policy
### Deploy EBS CSI driven storage class, external snapshotter and swap default storage class
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
```

# Delete the EKS cluster

### Before deleting the cluster, ensure that the CSI driver gets uninstalled
```
kubectl delete sc ebs-sc
kubectl delete -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
```
* Detatch the associated IAM policy is deleted from the IAM role, else it might lead to cluster deletion errors
* Then proceed to delete the cluster
```
cd $HOME/$CLUSTER_NAME
eksctl delete cluster -f $CLUSTER_NAME.yaml
```
### Special note for OIDC enablement
```
cp $HOME/eks-anywhere/eks-aws/eks-oidc.yaml $HOME/$CLUSTER_NAME/$CLUSTER_NAME-oidc.yaml
eksctl associate identityprovider -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME-oidc.yaml
```
