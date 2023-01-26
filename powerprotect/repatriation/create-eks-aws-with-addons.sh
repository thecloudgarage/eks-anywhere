read -p 'EKS AWS CLUSTER NAME: ' eksAwsClusterName
read -p 'EC2 provisioning, type spot or on-demand: ' ec2ProvisioningType
cd $HOME
rm -rf $eksAwsClusterName
CLUSTER_NAME=$eksAwsClusterName
rm -rf $HOME/$CLUSTER_NAME
mkdir -p $HOME/$CLUSTER_NAME
cd $HOME/$CLUSTER_NAME
cp $HOME/.ssh/id_rsa ~/eks
cp $HOME/.ssh/id_rsa.pub ~/eks.pub
cp $HOME/eks-anywhere/eks-aws/eks-$ec2ProvisioningType.yaml $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
sed -i "s/ekstest/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY eksctl create cluster -f $HOME/$CLUSTER_NAME/$CLUSTER_NAME.yaml --kubeconfig=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
KUBECONFIG=$HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-cluster.kubeconfig
rm -rf $HOME/temp-ebs-csi-driver-policy.json
cd $HOME && cat <<EOF > $HOME/temp-ebs-csi-driver-policy.json
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
EOF
# OPTION 1 TO ATTACH CSI DRIVER POLICY AS INLINE POLICY FOR EKS NODEGROUP ROLE
export eks_nodegroup_iam_role_name=$(aws iam list-roles | jq -r '.Roles[] | select(.RoleName|match("'$eksAwsClusterName-nodegroup'")) | .RoleName')
aws iam put-role-policy --role-name $eks_nodegroup_iam_role_name --policy-name ebsCsiDriverPolicy --policy-document file://./temp-ebs-csi-driver-policy.json
#
#
# NOT USED: OPTION 2 CAN BE USED ALTERNATIVELY TO CREATE A MANAGED POLICY AND ATTACH IT TO THE EKS NODEGROUP ROLE
#aws iam create-policy --policy-name Amazon_EBS_CSI_Driver --policy-document file://./temp-ebs-csi-driver-policy.json &> /dev/null
#export ebs_csi_driver_policy_arn=$(aws iam list-policies | jq -r '.Policies[] | select(.PolicyName|match("Amazon_EBS_CSI_Driver")) | .Arn')
#export eks_nodegroup_iam_role_name=$(aws iam list-roles | jq -r '.Roles[] | select(.RoleName|match("'$eksAwsClusterName-nodegroup'")) | .RoleName')
#aws iam attach-role-policy --policy-arn $ebs_csi_driver_policy_arn --role-name $eks_nodegroup_iam_role_name
#
#
#DEPLOY THE EBS CSI DRIVERS AND CREATE STORAGE CLASS
#EDIT THE EBS CSI RELEASE NUMBER BASED ON EBS CSI GITHUB GUIDANCE
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.14"
kubectl apply -f $HOME/eks-anywhere/eks-aws/ebs-sc.yaml
sleep 120
#
# DEPLOY EXTERNAL SNAPSHOTTER AND PATCH DEFAULT STORAGE CLASS
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/examples/kubernetes/snapshot/manifests/classes/snapshotclass.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
kubectl patch storageclass gp2 -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}"
kubectl patch storageclass ebs-sc -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}"
#
# DEPLOY POWERPROTECT SERVICE ACCOUNT AND RBAC
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-sa.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-rbac.yaml
