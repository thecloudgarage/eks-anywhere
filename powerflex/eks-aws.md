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

### Create a bare-bones EKS cluster
Please change the version as per your requirement
```
cat <<EOF > $CLUSTER_NAME/$CLUSTER_NAME.yaml
# Please change the name, region, vpc, subnet, instance type and other specs
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: ${CLUSTER_NAME}
  region: eu-west-1
  version: "1.27"
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
```
Create the cluster
```
eksctl create cluster -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml --kubeconfig=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
```
Verify the cluster
```
KUBECONFIG=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
kubectl get nodes
```
NOTE: Dell's SCINI tar files for various OS and kernels can be accessed via ftp://QNzgdxXix:Aw3wFAwAq3@ftp.emc.com

### Create the NodeGroup (k8s version 1.27 and below)
* Please change the AMI ID as per the cluster version. Canonical ubuntu AMI for EKS https://cloud-images.ubuntu.com/docs/aws/eks/
```
cat <<EOF > $CLUSTER_NAME/$CLUSTER_NAME-nodegroup.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: ${CLUSTER_NAME}
  region: eu-west-1
nodeGroups:
  - name: md-0
    labels:
      group: md-0
    instanceType: t2.medium
    amiFamily: Ubuntu2004
    ami: ami-06cea40b075348c5f
    privateNetworking: true
    desiredCapacity: 2
    securityGroups:
      attachIDs: ["sg-080b7c006220a6283"]
    volumeSize: 50
    ssh:
      publicKeyName: "eks-ssh"

    overrideBootstrapCommand: |
      #!/bin/bash
      # PLEASE READ CAREFULLY: https://eksctl.io/announcements/nodegroup-override-announcement/
      source /var/lib/cloud/scripts/eksctl/bootstrap.helper.sh

      # Note "--node-labels=\${NODE_LABELS}" needs the above helper sourced to work, otherwise will have to be defined manually.
      /etc/eks/bootstrap.sh \${CLUSTER_NAME} --container-runtime containerd --kubelet-extra-args "--node-labels=\${NODE_LABELS}" --apiserver-endpoint \${API_SERVER_URL} --b64-cluster-ca \${B64_CLUSTER_CA}
      #
      cd /home/ubuntu
      wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/get-powerflex-info.sh
      wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/eks-sdc-new.sh
      sed -i "s/mdm-ip-addresses/172.26.2.124,172.26.2.125,172.26.2.126/g" eks-sdc-new.sh
      #
      TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
      hostname=$(curl -s http://169.254.169.254/latest/meta-data/hostname -H "X-aws-ec2-metadata-token: \$TOKEN")
      sudo hostnamectl set-hostname \$hostname
      #
      chmod +x *.sh
      sudo ./eks-sdc-new.sh
EOF
```
Create the nodegroup
```
eksctl create nodegroup --config-file=$CLUSTER_NAME/$CLUSTER_NAME-nodegroup.yaml
```
Verify the nodes in the cluster
```
kubectl get nodes
```
### Verification
```
cd $CLUSTER_NAME
ssh -i ubuntu@node-ip
sudo ./get-powerflex-info.sh
```
You should see a similar output. Note the script is designed to rename the MDM-ID as System ID. This value is important for CSI driver installation.
```
sudo ./get-powerflex-info.sh
System ID         MDPM IPs
d7f6c6427c56ab0f  172.26.2.124 172.26.2.125 172.26.2.126
```
or manually use the sdc command
```
sudo su
/opt/emc/scaleio/sdc/bin/drv_cfg --query_mdms
```
You should see an output similar to one below
```
root@ip-172-26-2-148:~# /opt/emc/scaleio/sdc/bin/drv_cfg --query_mdms
Retrieved 1 mdm(s)
MDM-ID d7f6c6427c56ab0f SDC ID 59f89f6100000005 INSTALLATION ID 295ee6f776af5e4c IPs [0]-172.26.2.124 [1]-172.26.2.125 [2]-172.26.2.126
```
The MDM-ID is the most important attribute value to note as it is used for CSI driver installation and also for peering purposes.
### Installing the CSI driver
```
cd $CLUSTER_NAME
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/install-powerflex-csi-driver-nodegroups-eks-aws.sh
chmod +x install-powerflex-csi-driver-nodegroups-eks-aws.sh
./install-powerflex-csi-driver-nodegroups-eks-aws.sh
```
A sample is shown below for my configuration. We can observe that the nodeGroup is provided as md-0 such that the CSI drivers will be installed only on those nodes. Additionally, see the use of SystemID which is retrieved in the previous step. 
```
./install-powerflex-csi-driver-nodegroups-eks-aws.sh
Enter Cluster Name on which CSI driver needs to be installed
clusterName: c4-eks-apex-block
Enter PowerFlex CSI release version, e.g. 2.6.0
csiReleaseNumber: 2.6.0
Enter IP or FQDN of the powerflex cluster
ipOrFqdnOfPowerFlexCluster: 10.204.111.71
Enter Comma separated MDM IP addresses for powerflex cluster
ipAddressesOfMdmsForPowerFlexCluster: 172.26.2.124,172.26.2.125,172.26.2.126
Enter System Id of the powerflex cluster
systemIdOfPowerFlexCluster: d7f6c6427c56ab0f
Enter username of the powerflex cluster
userNameOfPowerFlexCluster: admin
Enter password of the powerflex cluster
passwordOfPowerFlexCluster: Enter Node Group name on which drivers will be installed, e.g. md-0
nodeSelectorGroupName: md-0
```
### Testing the driver
* To begin, create a volume in APEX Block-AWS and note the volume ID
* Download a sample MySQL and Adminer deployment file
```
cd $CLUSTER_NAME
wget https://github.com/thecloudgarage/eks-anywhere/blob/main/mysql/standalone/powerflex/aws-mysql-all-in-one.yaml
sed -i "s/volume-id/<replace with the volume-id>/g" aws-mysql-all-in-one.yaml
kubectl create -f aws-mysql-all-in-one.yaml
```
That's it!!!
```
