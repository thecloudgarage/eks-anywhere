### TAKE NOTE
Before starting ensure that the private subnets are tagged 
```
Key: kubernetes.io/role/internal-elb
Value: 1
```
Additionally all services that require an Internal NLB should be configured with the below annotations
```
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    service.beta.kubernetes.io/aws-load-balancer-scheme: internal
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
```

### Export variables
```
CLUSTER_NAME=c4-eks-aws-1
mkdir -p $CLUSTER_NAME
```

### Create Cluster
```
# The below command will create the YAML template for the cluster config. 
# Note the use of backticks., do not remove them
# This configuration will create an EKS cluster with a custom AMI (ubuntu 20.04 from canonical)
# Additionally, the cluster will reside in private subnet/s and does not bear outbound internet access
# Note the use of privatenetworking = true and override bootstrap commands

cat <<EOF > $CLUSTER_NAME/$CLUSTER_NAME.yaml
# Please change the name, region, vpc, subnet, instance type and other specs
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: ${CLUSTER_NAME}
  region: eu-west-1
vpc:
  publicAccessCIDRs: ["0.0.0.0/0"]
  id: "vpc-00bc8b021dafb7a92"  # (optional, must match VPC ID used for each subnet below)
  cidr: "172.26.0.0/22"       # (optional, must match CIDR used by the given VPC)
  clusterEndpoints:
    publicAccess: true
    privateAccess: true
  subnets:
    # must provide 'private' and/or 'public' subnets by availibility zone as shown
    private:
      subnet1:
        id: "subnet-05b6a79635031102c"
        cidr: "172.26.2.0/26" # (optional, must match CIDR used by the given subnet)

      subnet2:
        id: "subnet-029718643080a4b86"
        cidr: "172.26.2.64/26"  # (optional, must match CIDR used by the given subnet)

      subnet3:
        id: "subnet-01c68677ddab29f0c"
        cidr: "172.26.2.128/26"  # (optional, must match CIDR used by the given subnet)
nodeGroups:
  - name: md-0
    labels:
      group: md-0
    instanceType: t2.medium
    amiFamily: Ubuntu2004
    ami: ami-062ebd5f10a9d1a90
    privateNetworking: true
    desiredCapacity: 2
    securityGroups:
      attachIDs: ["sg-080b7c006220a6283"]
    volumeSize: 50
    ssh:
      publicKeyName: "test"

    overrideBootstrapCommand: |
      #!/bin/bash
      # PLEASE READ CAREFULLY: https://eksctl.io/announcements/nodegroup-override-announcement/
      source /var/lib/cloud/scripts/eksctl/bootstrap.helper.sh

      # Note "--node-labels=\${NODE_LABELS}" needs the above helper sourced to work, otherwise will have to be defined manually.
      # Big Note: Backticks supplied as we are creating a file via cat EOF
      # Do not remove backticks if cat EOF is used to create the file
      # if backtick is removed, the variable substitution will result in empty fields
      /etc/eks/bootstrap.sh \${CLUSTER_NAME} --container-runtime containerd --kubelet-extra-args "--node-labels=\${NODE_LABELS}" \
        --apiserver-endpoint \${API_SERVER_URL} --b64-cluster-ca \${B64_CLUSTER_CA}
      cd /home/ubuntu
      wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/eks-sdc-new.sh
      chmod +x eks-sdc-new.sh
      sudo ./eks-sdc-new.sh
EOF
```

### Create the EKS Cluster 
```
eksctl create cluster -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml --kubeconfig=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
KUBECONFIG=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
kubectl get nodes
```
### Verification
```
cd $CLUSTER_NAME
ssh -i ubuntu@node-ip
sudo su
/opt/emc/scaleio/sdc/bin/drv_cfg --query_mdms
```
