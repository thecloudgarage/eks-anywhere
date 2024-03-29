#!bin/bash
echo $(date +"%T")
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "${RED}#######################IMPORTANT NOTE#################################${NC}"
echo -e "${RED}keep the name of workload and management cluster EXACTLY THE SAME${NC}"
echo -e "${RED}in case of creating standlone workload clusters or management clusters${NC}"
echo -e "${RED}######################################################################${NC}"
read -p 'Workload cluster name: ' workloadClusterName
read -p 'Management cluster name: ' mgmtClusterName
read -p 'staticIp for API server High Availability: ' apiServerIpAddress
read -p 'Kubernetes version 1.21, 1.22, 1.23, etc.: ' -e -i '1.23' kubernetesVersion
#
echo "Enter PowerStore CSI release version, e.g. 2.2.0, 2.3.0, 2.4.0, 2.5.0"
read -p 'csiReleaseNumber: ' -e -i '2.5.0' csiReleaseNumber
echo "Enter IP or FQDN of the PowerStore array"
read -p 'ipOrFqdnOfPowerStoreArray: ' -e -i '172.24.185.106' ipOrFqdnOfPowerStoreArray
echo "Enter Global Id of the PowerStore Array"
read -p 'globalIdOfPowerStoreArray: ' -e -i 'PS4ebb8d4e8488' globalIdOfPowerStoreArray
echo "Enter username of the PowerStore Array"
read -p 'userNameOfPowerStoreArray: ' userNameOfPowerStoreArray
echo "Enter password of the PowerStore Array"
read -sp 'passwordOfPowerStoreArray: ' passwordOfPowerStoreArray
echo -e "\n"
#
read -p 'METALLB_START_IP: ' -e -i '172.24.165.21' METALLB_START_IP
echo "Enter MetalLB end IP for the address range"
read -p 'METALLB_END_IP: ' -e -i '172.24.165.25' METALLB_END_IP
#
echo "Enter Gitlab FQDN"
read -p 'GITLAB HOST: '  -e -i 'gitlab.oidc.thecloudgarage.com' GITLAB_HOST
echo "Enter Gitlab TCP port number"
read -p 'GITLAB PORT: ' -e -i '10443' GITLAB_PORT
echo "Enter Gitlab User Id"
read -p 'GITLAB USER ID: ' -e -i 'ambarhassani' GITLAB_USER_ID
echo "Enter Gitlab Repo name"
read -p 'GITLAB PROJECT NAME: ' -e -i 'powerofpartnership' GITLAB_PROJECT_NAME
echo "Enter Gitlab Project Token e.g. glpat-ygPK56A988e_pSbcbT9j"
read -sp 'GITLAB PROJECT TOKEN: ' GITLAB_PROJECT_TOKEN
GITLAB_PROJECT_TOKEN="${GITLAB_PROJECT_TOKEN:=glpat-ygPK56A988e_pSbcbT9j}"
echo -e "\n"
#
echo "Enter FQDN for ArgoCD server"
read -p 'ARGOCD_FQDN: ' -e -i 'argocd.oidc.thecloudgarage.com' ARGOCD_FQDN
echo "Enter FQDN for KeyCloak server"
read -p 'KEYCLOAK_FQDN: ' -e -i 'keycloak.thecloudgarage.com' KEYCLOAK_FQDN
#
if ping -c 1 $staticIp &> /dev/null
then
  echo "Error., cannot contintue...Static IP conflict, address in use"
else
if [ "$mgmtClusterName" == "$workloadClusterName" ]
then
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml \
        $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$workloadClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$mgmtClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/api-server-ip/$apiServerIpAddress/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/1.21/$kubernetesVersion/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster -f $HOME/$workloadClusterName-eks-a-cluster.yaml 2> >(grep -v "missing")
else
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml \
        $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$workloadClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$mgmtClusterName/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/api-server-ip/$apiServerIpAddress/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
sed -i "s/1.21/$kubernetesVersion/g" $HOME/$workloadClusterName-eks-a-cluster.yaml
eksctl anywhere create cluster \
  -f $HOME/$workloadClusterName-eks-a-cluster.yaml  \
  --kubeconfig $HOME/$mgmtClusterName/$mgmtClusterName-eks-a-cluster.kubeconfig 2> >(grep -v "missing")
fi
fi
#
# SWITCH KUBECTL CONTEXT TO THE WORKLOAD CLUSTER
printf "$workloadClusterName\n" | source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
source $HOME/.profile
#
# DEPLOY POWERSTORE CSI DRIVERS ALONG WITH STORAGE AND SNAPSHOT CLASSES
mkdir -p $HOME/$workloadClusterName
cd $HOME/$workloadClusterName
git clone -b v$csiReleaseNumber https://github.com/dell/csi-powerstore.git
cd $HOME/$workloadClusterName/csi-powerstore
#Added to accomodate higher releases of csi driver installations
eksdistroversion=$(kubectl get nodes -o=jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')
sed -i "s/>= 1.21.0 < 1.26.0/$eksdistroversion/g" helm/csi-powerstore/Chart.yaml
cd $HOME/$workloadClusterName/csi-powerstore
git clone https://github.com/kubernetes-csi/external-snapshotter/
cd ./external-snapshotter
git checkout release-5.0
kubectl kustomize client/config/crd | kubectl create -f -
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
kubectl create namespace csi-powerstore
cd $HOME/$workloadClusterName/csi-powerstore/dell-csi-helm-installer
cp $HOME/eks-anywhere/powerstore/secret.yaml secret.yaml
sed -i "s/powerstore_endpoint/$ipOrFqdnOfPowerStoreArray/g" $HOME/$workloadClusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
sed -i "s/powerstore_globalid/$globalIdOfPowerStoreArray/g" $HOME/$workloadClusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
sed -i "s/powerstore_username/$userNameOfPowerStoreArray/g" $HOME/$workloadClusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
sed -i "s/powerstore_password/$passwordOfPowerStoreArray/g" $HOME/$workloadClusterName/csi-powerstore/dell-csi-helm-installer/secret.yaml
kubectl create secret generic powerstore-config -n csi-powerstore --from-file=config=secret.yaml
cd $HOME/$workloadClusterName/csi-powerstore/dell-csi-helm-installer
cp $HOME/$workloadClusterName/csi-powerstore/helm/csi-powerstore/values.yaml my-powerstore-settings.yaml
sed -i "s/csivol/$workloadClusterName-vol/g" my-powerstore-settings.yaml
sed -i "s/csisnap/$workloadClusterName-snap/g" my-powerstore-settings.yaml
sed -i "s/csi-node/eksa-node/g" my-powerstore-settings.yaml
cd $HOME/$workloadClusterName/csi-powerstore/dell-csi-helm-installer
./csi-install.sh --namespace csi-powerstore --values ./my-powerstore-settings.yaml --skip-verify --skip-verify-node
cd $HOME/$workloadClusterName/csi-powerstore/dell-csi-helm-installer
cp $HOME/$workloadClusterName/csi-powerstore/samples/storageclass/powerstore-ext4.yaml ./powerstore-ext4-iscsi-storage-class.yaml
sed -i "s/Unique/$globalIdOfPowerStoreArray/g" $HOME/$workloadClusterName/csi-powerstore/dell-csi-helm-installer/powerstore-ext4-iscsi-storage-class.yaml
kubectl create -f $HOME/$workloadClusterName/csi-powerstore/dell-csi-helm-installer/powerstore-ext4-iscsi-storage-class.yaml
kubectl create -f $HOME/eks-anywhere/powerstore/powerstore-ext4-iscsi-snap-class.yaml
#
# CREATE METALLB LOAD BALANCER
helm upgrade --install --wait --timeout 15m   --namespace metallb-system --create-namespace   --repo https://metallb.github.io/metallb metallb metallb
sleep 30
cd $HOME/$workloadClusterName
rm -rf $HOME/$workloadClusterName/metallb-crd.yaml
cat <<EOF > $HOME/$workloadClusterName/metallb-crd.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - $METALLB_START_IP-$METALLB_END_IP
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF
kubectl create -f $HOME/$workloadClusterName/metallb-crd.yaml
sleep 5
#
#
# CREATE NGINX INGRESS CONTROLLER
cd $HOME
kubectl create -f $HOME/eks-anywhere/ingress-controllers/nginx-ingress-controller.yaml
#
# DEPLOY ARGOCD WITH OIDC AND CONNECT TO GITLAB REPO
cd $HOME
#
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd --namespace argocd --create-namespace --values - <<EOF
redis:
  enabled: true
redis-ha:
  enabled: false
server:
  service:
    type: LoadBalancer
    loadBalancerIP: $METALLB_END_IP
  config:
    url: "https://$ARGOCD_FQDN"
    application.instanceLabelKey: argocd.argoproj.io/instance
    admin.enabled: 'false'
    resource.exclusions: |
      - apiGroups:
          - cilium.io
        kinds:
          - CiliumIdentity
        clusters:
          - '*'
    oidc.config: |
      name: Keycloak
      issuer: "https://${KEYCLOAK_FQDN}/auth/realms/master"
      clientID: kube
      cliClientID: argocdcligrpc
      clientSecret: kube-client-secret
      requestedScopes: ['openid', 'profile', 'email', 'groups']
    oidc.tls.insecure.skip.verify: "true"
    resource.customizations.health.argoproj.io_Application: |
      hs = {}
      hs.status = "Progressing"
      hs.message = ""
      if obj.status ~= nil then
        if obj.status.health ~= nil then
          hs.status = obj.status.health.status
          if obj.status.health.message ~= nil then
            hs.message = obj.status.health.message
          end
        end
      end
      return hs
  rbacConfig:
    policy.default: role:readonly
    policy.csv: |
      g, kube-admin, role:admin
EOF
#
# CREATE TLS FOR GITLAB REPO IN ARGOCD
echo -e "${RED}SCAN AND DOWNLOAD GITLAB SSL CERTIFICATE${NC}"
cd $HOME
#
echo -n | openssl s_client -connect $GITLAB_HOST:$GITLAB_PORT \
-servername $GITLAB_HOST \
| openssl x509 > $HOME/$GITLAB_HOST
#
echo -e "${RED}PREPARE PATCH FILE FOR GITLAB SSL CERTIFICATE IN ARGOCD${NC}"
kubectl create configmap argocd-tls-certs-cm \
-n argocd --from-file $GITLAB_HOST \
--dry-run=client -o yaml > argocd-tls-certs-cm.yaml
#
echo -e "${RED}ADD GITLAB SSL CERTIFICATE IN ARGOCD${NC}"
kubectl patch configmap argocd-tls-certs-cm \
-n argocd --patch-file argocd-tls-certs-cm.yaml
#
echo -e "${RED}CONNECT GITLAB REPO WITH ARGOCD${NC}"
# CREATE GITLAB REPO ENTRY IN ARGOCD
#
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: "https://$GITLAB_HOST:$GITLAB_PORT/$GITLAB_USER_ID/$GITLAB_PROJECT_NAME.git"
  password: $GITLAB_PROJECT_TOKEN
  username: git
EOF
#
# REGISTER EKS-A CLUSTER WITH AWS CONSOLE
cd $HOME/$workloadClusterName
if AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
        eksctl register cluster --name $workloadClusterName --provider eks_anywhere --region $AWS_REGION > /dev/null 2>&1
then
CLUSTER_NAME=$workloadClusterName
KUBECONFIG=$HOME/$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
mkdir eks-connector
mv eks-connector.yaml eks-connector/
mv eks-connector-clusterrole.yaml eks-connector/
mv eks-connector-console-dashboard-full-access-group.yaml eks-connector/
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector.yaml
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector-clusterrole.yaml
kubectl apply -f /home/ubuntu/$workloadClusterName/eks-connector/eks-connector-console-dashboard-full-access-group.yaml
cd /home/ubuntu
echo "EKS ANYWHERE cluster $workloadClusterName is registered in AWS console"
#
#
else
echo "DON'T FRET SERVICE-ROLE PROPAGATION IS IN PROGRESS, WAIT FOR 30 SECONDS"
echo "DON'T FRET SERVICE-ROLE PROPAGATION IS IN PROGRESS, WAIT FOR 30 SECONDS"
echo "DON'T FRET SERVICE-ROLE PROPAGATION IS IN PROGRESS, WAIT FOR 30 SECONDS"
sleep 30
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
        eksctl register cluster --name $workloadClusterName --provider eks_anywhere --region $AWS_REGION
CLUSTER_NAME=$workloadClusterName
KUBECONFIG=/home/ubuntu/$workloadClusterName/$workloadClusterName-eks-a-cluster.kubeconfig
mkdir eks-connector
mv eks-connector.yaml eks-connector/
mv eks-connector-clusterrole.yaml eks-connector/
mv eks-connector-console-dashboard-full-access-group.yaml eks-connector/
kubectl apply -f $HOME/$workloadClusterName/eks-connector/eks-connector.yaml
kubectl apply -f $HOME/$workloadClusterName/eks-connector/eks-connector-clusterrole.yaml
kubectl apply -f $HOME/$workloadClusterName/eks-connector/eks-connector-console-dashboard-full-access-group.yaml
cd /home/ubuntu
echo "EKS ANYWHERE cluster $workloadClusterName is registered in AWS console"
fi
echo $(date +"%T")
