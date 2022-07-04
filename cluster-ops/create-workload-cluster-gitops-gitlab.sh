#!bin/bash
echo "IS THIS WORKLOAD CLUSTER MANAGED BY A DEDICATED MANAGEMENT CLUSTER, if not then leave mgmtClusterName BLANK"
read -p 'mgmtClusterName: ' mgmtClusterName
read -p 'workloadClusterName: ' workloadClusterName
read -p 'staticIp for API server High Availability: ' staticIp
read -p 'gitlabFQDN: ' gitlabFQDN
read -p 'gitlabSshPort: ' gitlabSshPort
read -p 'gitlabUsername: ' gitlabUsername
read -p 'gitlabFluxClusterRepo: ' gitlabFluxClusterRepo
if ping -c 1 $staticIp &> /dev/null
then
  echo "Error., cannot contintue...Static IP conflict, address in use"
else
if [ -z "$mgmtClusterName" ]
then
cd /home/ubuntu/
cp /home/ubuntu/eks-anywhere/cluster-samples/workload-eks-a-cluster-sample.yaml \
        /home/ubuntu/$workloadClusterName-eks-a-cluster.yaml
#NOTE HOW WE ARE USING SED TO INSERT THE GITOPS REF CONFIG AT THE TOP OF THE SPEC PRECEDING THE KEYWORK clusterNetwork:
sed -i '/clusterNetwork:/i \
  gitOpsRef:\
    kind: FluxConfig\
    name: mgmt' $HOME/$workloadClusterName-eks-a-cluster.yaml
#NOTE HOW WE ARE USING SED TO INSERT THE ENTIRE FLUX CONFIG AT THE END OF THE YAML FILE
sed -i '$a\
apiVersion: anywhere.eks.amazonaws.com/v1alpha1\
kind: FluxConfig\
metadata:\
  name: mgmt\
  namespace: default\
spec:\
  branch: main\
  clusterConfigPath: clusters/mgmt\
  git:\
    repositoryUrl: ssh://git@gitlabFQDN:gitlabSshPort/gitlabUsername/gitlabFluxClusterRepo.git\
    sshKeyAlgorithm: ecdsa\
  systemNamespace: flux-system\
\
---' $HOME/$workloadClusterName-eks-a-cluster.yaml

sed -i "s/workloadclustername/$workloadClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/staticIp/$staticIp/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/gitlabFQDN/$gitlabFQDN/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/gitlabSshPort/$gitlabSshPort/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/gitlabUsername/$gitlabUsername/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/gitlabFluxClusterRepo/$gitlabFluxClusterRepo/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster -f $HOME/$workloadClusterName-eks-a-cluster.yaml
else
cd /home/ubuntu/
cp /home/ubuntu/eks-anywhere/cluster-samples/workload-eks-a-cluster-sample.yaml \
        /home/ubuntu/$workloadClusterName-eks-a-cluster.yaml
#NOTE HOW WE ARE USING SED TO INSERT THE GITOPS REF CONFIG AT THE TOP OF THE SPEC PRECEDING THE KEYWORK clusterNetwork:
sed -i '/clusterNetwork:/i \
  gitOpsRef:\
    kind: FluxConfig\
    name: mgmt' $HOME/$workloadClusterName-eks-a-cluster.yaml
#NOTE HOW WE ARE USING SED TO INSERT THE ENTIRE FLUX CONFIG AT THE END OF THE YAML FILE
sed -i '$a\
apiVersion: anywhere.eks.amazonaws.com/v1alpha1\
kind: FluxConfig\
metadata:\
  name: mgmt\
  namespace: default\
spec:\
  branch: main\
  clusterConfigPath: clusters/mgmt\
  git:\
    repositoryUrl: ssh://git@gitlabFQDN:gitlabSshPort/gitlabUsername/gitlabFluxClusterRepo.git\
    sshKeyAlgorithm: ecdsa\
  systemNamespace: flux-system\
\
---' $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/workloadclustername/$workloadClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/staticIp/$staticIp/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/gitlabFQDN/$gitlabFQDN/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/gitlabSshPort/$gitlabSshPort/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/gitlabUsername/$gitlabUsername/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/gitlabFluxClusterRepo/$gitlabFluxClusterRepo/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster \
  -f /home/ubuntu/$workloadClusterName-eks-a-cluster.yaml  \
  --kubeconfig $HOME/$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig
fi
fi
