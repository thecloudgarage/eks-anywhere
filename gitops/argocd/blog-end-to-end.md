:raising_hand: Please ensure that Kubernetes v1.22 or above is used for the OS and cluster template
* Create an EKS Anywhere cluster
```
CLUSTER_NAME=odyssey
API_SERVER_IP=172.24.165.14
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/test-eks-anywhere/eks-anywhere/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
eksctl anywhere create cluster -f $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
```
Switch kubectl context
```
cd $HOME
source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
```
Validate kubectl access
```
kubectl get nodes
```
Install PowerStore CSI
```
cd $HOME
source eks-anywhere/powerstore/install-powerstore-csi-driver.sh

clusterName: ambar01              
Enter IP or FQDN of the PowerStore array
ipOrFqdnOfPowerStoreArray: 172.24.185.106
Enter Global Id of the PowerStore Array
globalIdOfPowerStoreArray: PS4ebb8d4e8488 
Enter username of the PowerStore Array
userNameOfPowerStoreArray: iac
Enter password of the PowerStore Array
passwordOfPowerStoreArray:
```
Install MetalLB load balancer
```
helm upgrade --install --wait --timeout 15m   --namespace metallb-system --create-namespace   --repo https://metallb.github.io/metallb metallb metallb
```
Configure MetalLB pools and advertisements
```
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.24.165.31-172.24.165.35
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF
```
Install ArgoCD with OIDC (KeyCloak)
```
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
  config:
    url: https://argocdtest.oidc.thecloudgarage.com
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
      issuer: http://keycloak.thecloudgarage.com/auth/realms/master
      clientID: kube
      cliClientID: argocdcligrpc
      clientSecret: kube-client-secret
      requestedScopes: ['openid', 'profile', 'email', 'groups']
    oidc.tls.insecure.skip.verify: "true"
  rbacConfig:
    policy.default: role:readonly
    policy.csv: |
      g, kube-admin, role:admin
EOF
```
Install NGINX Ingress Controller
```
cd $HOME
kubectl apply -f eks-anywhere/sock-shop/ingress-controller-nginx.yaml
```
Create an empty project in Gitlab and setup a project access token. Note the values once the project is created
```
gitlab project name: https://gitlab.oidc.thecloudgarage.com:10443/ambarhassani/odyssey.git
gitlab project token: ????
```
Export the variables for Gitlab commits
```
EKSA_WORKLOAD_CLUSTER_NAME=odyssey
EKSA_MGMT_CLUSTER_NAME=odyssey
GITLAB_PROJECT_NAME=odyssey
```
Configure git client on the EKS Anywhere Administrative machine
```
git config --global user.email "ambar@thecloudgarage.com"
git config --global user.name "ambar@thecloudgarage"
```
Clone the Gitlab project on the EKS Anywhere Administrative machine
```
GIT_SSL_NO_VERIFY=true git clone https://gitlab.oidc.thecloudgarage.com:10443/ambarhassani/$GITLAB_PROJECT_NAME.git
```
ClusterOPS: Copy the existing EKSA cluster configuration YAML to cloned gitlab repo
```
cd $HOME
mkdir -p $HOME/$GITLAB_PROJECT_NAME/clusters/$EKSA_MGMT_CLUSTER_NAME/$EKSA_WORKLOAD_CLUSTER_NAME/eksa-system
cp $HOME/$CLUSTER_NAME/$CLUSTER_NAME-eks-a-cluster.yaml \
$HOME/$GITLAB_PROJECT_NAME/clusters/$EKSA_MGMT_CLUSTER_NAME/$EKSA_WORKLOAD_CLUSTER_NAME/eksa-system
```
AppOPS: Copy the Sockshop application manifests into the cloned gitlab repo
```
cd $HOME
mkdir -p $HOME/$GITLAB_PROJECT_NAME/applications/sockshop/ 
cp $HOME/eks-anywhere/sock-shop/gitops/sockshop* $HOME/$GITLAB_PROJECT_NAME/applications/sockshop/
```
Verify the structure of the local repo
```
tree $HOME/$GITLAB_PROJECT_NAME
```
Commit and push the EKSA cluster and Sockshop application files on to the Gitlab project
```
cd $HOME/$GITLAB_PROJECT_NAME
git branch -M main
git add --all
git commit -m "Adding EKSA cluster and Sockshop application manifests for GitOps"
GIT_SSL_NO_VERIFY=true git push -uf origin main
```
### Configure ArgoCD and create two separate applications
* Open windows cmd and change path to the directory where argocd cli is installed
* Export the required variables
```
set GITLAB_HOST="gitlab.oidc.thecloudgarage.com"
set GITLAB_PROJECT="https://gitlab.oidc.thecloudgarage.com:10443/ambarhassani/odyssey.git"
set GITLAB_PROJECT_TOKEN=????
set ARGOCD_HOST="argocdtest.thecloudgarage.com"
```
* Login to argocd via cli with OIDC or non-OIDC
* Example for OIDC
```
argocd login %ARGOCD_HOST% --sso
```
Add the TLS certificate for the Gitlab repository. Open the Gitlab repo in a browser. As it is a self-signed certificate, click on Not Secure > certificate > detail and Export. This will export the self signed certificate in a .crt format. Save the file in the same directory as argocd cli is installed and change the name to a simple one, e.g. gitlab-host
```
argocd cert add-tls --from gitlab-host.crt %GITLAB_HOST%
```
Add the Gitlab Repository
```
argocd repo add %GITLAB_PROJECT% --username git --password %GITLAB_PROJECT_TOKEN% --insecure-skip-server-verification
```
Add the Application Sockshop
```
argocd app create sockshop --repo %GITLAB_PROJECT% --path applications/sockshop --dest-server https://kubernetes.default.svc --directory-recurse --sync-policy none
```
Add the Application for EKS Anywhere cluster management
```
argocd app create eksa-cluster-testcluster --repo %GITLAB_PROJECT% --path clusters/odyssey --dest-server https://kubernetes.default.svc --directory-recurse --sync-policy none
```
### Validate Sockshop deployment via GitOps ArgoCD
* As soon as the application is created, argocd will initate the sync if policy is automatic. 
* In this case we will manually sync the sockshop application
* As a result, we can observe that ArgoCD has invoked the baseline commit and created the sock-shop application
* This can be viewed from the pods, persistent volumes, ingress and tls secret created in the sock-shop namespace
* In addition, we can observe that the persistent volumes have been created on the PowerStore array via csi
```
cd $HOME
kubectl get pods -n sock-shop
kubectl get pvc -n sock-shop
kubectl get ingress -n sock-shop
kubectl get secret -n sock-shop
```
* Next, let's login to the sockshop application via https://sockshop.thecloudgarage.com
* Create a demo user
* Initiate the ordering workflow and place an order

### Validate EKS Anywhere cluster baseline sync
* As soon as the application is created, argocd will initate the sync based on the committed cluster's YAML in gitlab
* As a result, we can observe that ArgoCD has invoked the baseline sync
* No changes will be executed as the cluster's YAML file in gitlab and the current state are in full sync

### SCENARIO-1 Sockshop scaling using ArgoCD
* Let's invoke ArgoCD based change management for the sockshop application
* SSH into EKS Anywhere administrative machine
* We will first change the manifest file to increase the front-end replicas from existing 1 to 3
```
sed -i "355s/1/3/g" $HOME/$GITLAB_PROJECT_NAME/applications/sockshop/sockshop-complete-application.yaml
```
* Next, we will increase the size of the persistent volumes from 8Gi to 10Gi
```
sed -i "s/8Gi/10Gi/g" $HOME/$GITLAB_PROJECT_NAME/applications/sockshop/sockshop-complete-application.yaml
```
* Let's commit a new version of the sock-shop manifest to GitLab with the above changes
```
cd $HOME/$GITLAB_PROJECT_NAME
git branch -M main
git add --all
git commit -m "Scale UP sockshop frontend replicas and increase size of persistent volumes"
GIT_SSL_NO_VERIFY=true git push -uf origin main
```
* Head over to ArgoCD and initiate the sync
* Note the change in the state of sockshop applications (frontend replicas and persistent volume sizes)
* Login to https://sockshop.thecloudgarage.com and validate if application state and workflows are intact
* Next we will observe the scale down effect in front-end replicas from 3 to 2
```
sed -i "355s/3/2/g" $HOME/$GITLAB_PROJECT_NAME/applications/sockshop/sockshop-complete-application.yaml
```
### Scenario-2 Cluster scaling using ArgoCD (Horizontal and vertical scaling/downscaling)
* Edit the EKS Anywhere cluster configuration in the local repo directory
* Change the count of worker node machines to reflect horizontal scaling
```
  workerNodeGroupConfigurations:
  - count: 2 <<<<< change this value to 3
```
* Commit to gitlab repo
```
cd $HOME/$GITLAB_PROJECT_NAME
git branch -M main
git add --all
git commit -m "Horizontal scaling for EKS Anywhere worker nodes"
GIT_SSL_NO_VERIFY=true git push -uf origin main
```
* Initiate the manual sync and observe the ArgoCD execution alongwith the state of cluster via kubectl and vsphere
* Also validate the sockshop application functionality
* Next, let's increase the vCPU and memory size for each of the worker nodes
* This will create new nodes
* Edit the EKS Anywhere cluster YAML in the cloned gitlab local repo
* Change memory from 8192 to 16384 for the worker nodes vSphere machine confiugration
* Change vCPU from 2 to 4 for the worker nodes vSphere machine confiugration
```
---
apiVersion: anywhere.eks.amazonaws.com/v1alpha1
kind: VSphereMachineConfig
metadata:
  name: odyssey-wk
  namespace: default
spec:
  datastore: /IAC-SSC/datastore/CommonDS
  diskGiB: 25
  folder: /IAC-SSC/vm/test-eks-anywhere
  memoryMiB: 8192 <<<< CHANGE THIS TO 16384
  numCPUs: 2 <<<< CHANGE THIS TO 4
  osFamily: ubuntu
  resourcePool: /IAC-SSC/host/IAC/Resources/Test
  template: /IAC-SSC/vm/Templates/ubuntu-2004-kube-v1.22
```
* Commit the changes to gitlab repo
```
cd $HOME/$GITLAB_PROJECT_NAME
git branch -M main
git add --all
git commit -m "Vertical scaling for EKS Anywhere worker nodes"
GIT_SSL_NO_VERIFY=true git push -uf origin main
```
* Initiate the manual sync and obbserve the ArgoCD execution and the state of the cluster via kubectl and vsphere
* Also validate the sockshop application functionality
* Next we will downscale the EKS Anywhere cluster to perform Horizontal and Vertical changes in a single take
* Edit the EKS Anywhere cluster configuration in the local repo directory
* Change the count of worker node machines to reflect horizontal scaling
```
  workerNodeGroupConfigurations:
  - count: 3 <<<<< change this value to 2
```
* Also change the vCPU and the memory size for the worker node machines
```
---
apiVersion: anywhere.eks.amazonaws.com/v1alpha1
kind: VSphereMachineConfig
metadata:
  name: odyssey-wk
  namespace: default
spec:
  datastore: /IAC-SSC/datastore/CommonDS
  diskGiB: 25
  folder: /IAC-SSC/vm/test-eks-anywhere
  memoryMiB: 16384 <<<< CHANGE THIS TO 8192
  numCPUs: 4 <<<< CHANGE THIS TO 2
  osFamily: ubuntu
  resourcePool: /IAC-SSC/host/IAC/Resources/Test
  template: /IAC-SSC/vm/Templates/ubuntu-2004-kube-v1.21.14
```
* Commit the changes to gitlab repo
```
cd $HOME/$GITLAB_PROJECT_NAME
git branch -M main
git add --all
git commit -m "Horizontal and vertical downscaling for EKS Anywhere worker nodes"
GIT_SSL_NO_VERIFY=true git push -uf origin main
```
### SCENARIO-3 Data Protection using Dell's PPDM and intersection with ArgoCD GitOps
* We will protect the sockshop application running on the EKS Anywhere cluster
* Setup Service Account, RBAC and volume snapshot class on the EKS Anywhere cluster
```
cd $HOME
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-sa.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-rbac.yaml
kubectl apply -f $HOME/eks-anywhere/powerprotect/powerprotect-volumesnapshotclass.yaml
```
* Retrieve the service account token
```
SA_NAME="powerprotect"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep ${SA_NAME} | awk '{print $1}')
```
* Discover the EKS Anywhere cluster as an asset along with all the resources
* Create the protection policies for the namespace sock-shop
* Initiate backup
* Delete the namespace of sock-shop
* Ideally, if automated sync was enabled ArgoCD will ensure that the resources are brought back up
* In this case, we will initiate a manual sync via ArgoCD
* Note that the sync will only restore the resources and not the data within the application
* Validate if argocd reinstates the resource state for sock-shop application via GitOps
* Although, ArgoCD has recreated sock-shop resources, however we cannot login via the demo user created earlier
* Recover the sock-shop application state via PowerProtect restore
* Validate the sock-shop application via the demo user login and validate the order id is persisted via the restore operation
