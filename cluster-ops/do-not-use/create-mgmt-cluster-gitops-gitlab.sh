#!bin/bash
read -p 'mgmtClusterName: ' mgmtClusterName
read -p 'staticIp: ' staticIp
read -p 'gitlabFQDN: ' gitlabFQDN
read -p 'gitlabSshPort: ' gitlabSshPort
read -p 'gitlabUsername: ' gitlabUsername
read -p 'gitlabFluxClusterRepo: ' gitlabFluxClusterRepo
export EKSA_GIT_PRIVATE_KEY=$HOME/.ssh/gitlab
export EKSA_GIT_KNOWN_HOSTS=$HOME/.ssh/my_eksa_known_hosts
if ping -c 1 $staticIp &> /dev/null
then
  echo "Error., cannot contintue...Static IP conflict, address in use"
else
export $mgmtClusterName
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/mgmt-eks-a-cluster-sample.yaml $HOME/$mgmtClusterName-eks-a-cluster.yaml
#NOTE HOW WE ARE USING SED TO INSERT THE GITOPS REF CONFIG AT THE TOP OF THE SPEC PRECEDING THE KEYWORK clusterNetwork:
sed -i '/clusterNetwork:/i \
  gitOpsRef:\
    kind: FluxConfig\
    name: mgmt' $HOME/$mgmtClusterName-eks-a-cluster.yaml
#NOTE HOW WE ARE USING SED TO INSERT THE ENTIRE FLUX CONFIG AT THE END OF THE YAML FILE
sed -i '$a\
apiVersion: anywhere.eks.amazonaws.com/v1alpha1\
kind: FluxConfig\
metadata:\
  name: mgmt\
spec:\
  branch: main\
  clusterConfigPath: clusters/mgmt\
  git:\
    repositoryUrl: ssh://git@gitlabFQDN:gitlabSshPort/gitlabUsername/gitlabFluxClusterRepo.git\
    sshKeyAlgorithm: ecdsa\
\
---' $HOME/$mgmtClusterName-eks-a-cluster.yaml
sed -i "s/staticIp/$staticIp/g" $HOME/$mgmtClusterName-eks-a-cluster.yaml
sed -i "s/mgmt/$mgmtClusterName/g" $HOME/$mgmtClusterName-eks-a-cluster.yaml
sed -i "s/gitlabFQDN/$gitlabFQDN/g" $HOME/$mgmtClusterName-eks-a-cluster.yaml
sed -i "s/gitlabSshPort/$gitlabSshPort/g" $HOME/$mgmtClusterName-eks-a-cluster.yaml
sed -i "s/gitlabUsername/$gitlabUsername/g" $HOME/$mgmtClusterName-eks-a-cluster.yaml
sed -i "s/gitlabFluxClusterRepo/$gitlabFluxClusterRepo/g" $HOME/$mgmtClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster -f $HOME/$mgmtClusterName-eks-a-cluster.yaml
fi
