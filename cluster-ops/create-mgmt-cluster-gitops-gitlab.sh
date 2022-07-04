#!bin/bash
read -p 'mgmtClusterName: ' mgmtClusterName
read -p 'staticIp: ' staticIp
read -p 'gitlabFQDN: ' gitlabFQDN
read -p 'gitlabSshPort: ' gitlabSshPort
read -p 'gitlabUsername: ' gitlabUsername
read -p 'gitlabFluxClusterRepo: ' gitlabFluxClusterRepo
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
    name: $mgmtClusterName' $HOME/$mgmtClusterName-eks-a-cluster.yaml
#NOTE HOW WE ARE USING SED TO INSERT THE ENTIRE FLUX CONFIG AT THE END OF THE YAML FILE
sed -i '$a\
apiVersion: anywhere.eks.amazonaws.com/v1alpha1\
kind: FluxConfig\
metadata:\
  name: $mgmtClusterName\
  namespace: default\
spec:\
  branch: main\
  clusterConfigPath: clusters/$mgmtClusterName\
  git:\
    repositoryUrl: ssh://git@$gitlabFQDN:$gitlabSshPort/$gitlabUsername/$gitlabFluxClusterRepo.git\
    sshKeyAlgorithm: ecdsa\
  systemNamespace: flux-system\
\
---' $HOME/$mgmtClusterName-eks-a-cluster.yaml
sed -i "s/staticIp/$staticIp/g" /home/ubuntu/$mgmtClusterName-eks-a-cluster.yaml
sed -i "s/mgmt/$mgmtClusterName/g" /home/ubuntu/$mgmtClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster -f /home/ubuntu/$mgmtClusterName-eks-a-cluster.yaml
fi
