# Create EKS Cluster with template
* Ensure aws-cli is set along with credentials and region
```
cd $HOME
CLUSTER_NAME=<name-of-the-intented-eks-cluster>
mkdir $CLUSTER_NAME
ssh-keygen
cd $HOME/$CLUSTER_NAME
cp $HOME/.ssh/id_rsa ~/eks
cp $HOME/.ssh/id_rsa.pub ~/eks.pub
cp $HOME/eks-anywhere/eks-aws/eks.yaml $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
sed -i "s/ekstest/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
eksctl create cluster -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml --kubeconfig=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
KUBECONFIG=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
kubectl get nodes
```
# For EBS CSI Driver
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
* Deploy the EBS CSI driver
```
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
kubectl get pods -n kube-system
```
### Before deleting the cluster, ensure that the CSI driver gets uninstalled & the associated IAM policy is deleted from the IAM role, else it might lead to cluster deletion errors

# For OIDC

```
cp $HOME/eks-anywhere/eks-aws/eks-oidc.yaml $HOME/$CLUSTER_NAME/$CLUSTER_NAME-oidc.yaml
eksctl associate identityprovider -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME-oidc.yaml
```
