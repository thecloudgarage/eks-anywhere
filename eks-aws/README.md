Ensure aws-cli is set along with credentials and region
```
cd $HOME
CLUSTER_NAME=<name-of-the-intented-eks-cluster>
mkdir $CLUSTER_NAME
ssh-keygen
cp $HOME/.ssh/id_rsa* $HOME/$CLUSTER_NAME
cd $HOME/$CLUSTER_NAME
mv id_rsa eks
mv id_rsa.pub eks.pub
cp $HOME/eks-anywhere/eks-aws/eks.yaml $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
sed -i "s/ekstest/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
cp $HOME/eks-anywhere/eks-aws/eks-oidc.yaml $HOME/$CLUSTER_NAME/$CLUSTER_NAME-oidc.yaml
eksctl create cluster -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml --kubeconfig=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
eksctl associate identityprovider -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME-oidc.yaml
```
