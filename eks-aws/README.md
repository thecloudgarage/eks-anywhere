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
cp $HOME/eks-anywhere/eksaws/eks.yaml $CLUSTER_NAME.yaml
cp $HOME/eks-anywhere/eksaws/eks-oidc.yaml $CLUSTER_NAME-oidc.yaml
eksctl create cluster -f $CLUSTER_NAME.yaml --kubeconfig=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
eksctl associate identityprovider -f $CLUSTER_NAME-oidc.yaml
```
