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
  - 172.24.165.31-172.24.165.31
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
helm upgrade --install --wait --atomic --namespace argocd --create-namespace  --repo https://argoproj.github.io/argo-helm argocd argo-cd --values - <<EOF
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
Note your GitLab Hostname
```
gitlab.oidc.thecloudgarage.com
```
Copy your Gitlab SSL certificate
```
-----BEGIN CERTIFICATE-----
MIIDxzCCAq+gAwIBAgIUaLVADwFp9QxHmGy3mYnVQa8rtBIwDQYJKoZIhvcNAQEL
BQAwdTELMAkGA1UEBhMCSU4xCzAJBgNVBAgMAk1IMQ8wDQYDVQQHDAZNdW1iYWkx
DjAMBgNVBAoMBXN0YWNrMQ8wDQYDVQQLDAZkZXZvcHMxJzAlBgNVBAMMHmdpdGxh
Yi5vaWRjLnRoZWNsb3VkZ2FyYWdlLmNvbTAeFw0yMjA5MjMxMTUxMTNaFw0yNDA5
MjIxMTUxMTNaMHUxCzAJBgNVBAYTAklOMQswCQYDVQQIDAJNSDEPMA0GA1UEBwwG
TXVtYmFpMQ4wDAYDVQQKDAVzdGFjazEPMA0GA1UECwwGZGV2b3BzMScwJQYDVQQD
DB5naXRsYWIub2lkYy50aGVjbG91ZGdhcmFnZS5jb20wggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQDF4sZVtM10OpA/uCxcM0kRsP8iCIGcasWzqOyryT2c
1HpwdjoPEOqfi1dDsLE/z1PTKUI+JKRuquqdmSSjyFQJ7c82gQPNb8qLVmdLHJOm
nWzgvG5KuNT8UReHzDxy53D/MBV1fSBo4PT94OvuYVfP2iDiMX6uUtIosdmWfmXe
8XKUJFQmFOIL7olvz035m1PU5OKKAwrUjbwoxjt6Ll0EJAOj+okKvxc6MLmOOCKJ
G/tuOU/t0b2JhHQ2uaP2dF/Y857QCaKK5B1MD4+DjO5zPROB+W6J2Mw6MxFIdNu+
moZ8lSpN139zXE1KsruLhUPlo3Ix42ZTLRf0mEb5ARgtAgMBAAGjTzBNMAsGA1Ud
DwQEAwIFoDATBgNVHSUEDDAKBggrBgEFBQcDATApBgNVHREEIjAggh5naXRsYWIu
b2lkYy50aGVjbG91ZGdhcmFnZS5jb20wDQYJKoZIhvcNAQELBQADggEBAAAVMX2g
Wyl94nnBKDyc5B4OGDLbe3Vdcz2TsP4krV4lQBMNvHZIxk34S+ZUHxn2sSL4ngWA
oD/5WNA7kbvvrPY4Vzwy5KbNWeoCfZKN/kF4EmwSIHj7zkNeZD7aTuq0zr0DRcE4
3J982k/NVDygZtJcT+5ZNyyubDUi628DC5aAUkmrAOUDty7UNPJnhfYyPo2flcxQ
0t/Gb2P9sVUvoTgTG+1OEKVN4AWVvxQxNrb/pwY8dHI4w9zvdnjeOo7msxwX6er8
/Ja1Gfl4sL94+5IgNH8iLfPTYtlPKXy4mWF+F9ACdH6qw86BjzrN8yd1o9h8K8mJ
cutlsswicv0xPuk=
-----END CERTIFICATE-----
```
Create an empty project in Gitlab and setup a project access token. Note the values once the project is created
```
gitlab project name: https://gitlab.oidc.thecloudgarage.com:10443/ambarhassani/odyssey.git
gitlab project token: glpat-Ux54LhTLBnR8t6Yqsw47
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
cd $HOME
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
* We can observe that ArgoCD has invoked the baseline commit and created the sock-shop application
* This can be viewed from the pods, persistent volumes, ingress and tls secret created in the sock-shop namespace
* In addition, we can observe that the persistent volumes have been created on the PowerStore array via csi
```
cd $HOME
kubectl get pods -n sock-shop
kubectl get pvc -n sock-shop
kubectl get ingress -n sock-shop
kubectl get secret -n sock-shop
```
### SCENARIO-1 Sockshop scaling using ArgoCD
* Let's invoke ArgoCD based change management for the sockshop application
* We will first change the manifest file to increase the front-end replicas from existing 1 to 5
```
sed -i "355s/1/5/g" $HOME/$GITLAB_PROJECT_NAME/applications/sockshop/sockshop-complete-application.yaml
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
* Head over to ArgoCD and observe the execution of these changes
* Note the change in the state of sockshop applications (frontend replicas and persistent volume sizes)
* Next we will observe the scale down effect in front-end replicas from 5 to 2
```
sed -i "355s/5/2/g" $HOME/$GITLAB_PROJECT_NAME/applications/sockshop/sockshop-complete-application.yaml
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
* Observe the ArgoCD execution and the state of the cluster via kubectl and vsphere
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
  name: ambar01-wk
  namespace: default
spec:
  datastore: /IAC-SSC/datastore/CommonDS
  diskGiB: 25
  folder: /IAC-SSC/vm/test-eks-anywhere
  memoryMiB: 8192 <<<< CHANGE THIS TO 16384
  numCPUs: 2 <<<< CHANGE THIS TO 4
  osFamily: ubuntu
  resourcePool: /IAC-SSC/host/IAC/Resources/Test
  template: /IAC-SSC/vm/Templates/ubuntu-2004-kube-v1.21.14
```
* Commit the changes to gitlab repo
```
cd $HOME/$GITLAB_PROJECT_NAME
git branch -M main
git add --all
git commit -m "Vertical scaling for EKS Anywhere worker nodes"
GIT_SSL_NO_VERIFY=true git push -uf origin main
```
* Observe the ArgoCD execution and the state of the cluster via kubectl and vsphere
* Also validate the sockshop application functionality
* Next we will downscale the EKS Anywhere cluster to perform Horizontal and Vertical changes in a single take
* Edit the EKS Anywhere cluster configuration in the local repo directory
* Change the count of worker node machines to reflect horizontal scaling
```
  workerNodeGroupConfigurations:
  - count: 3 <<<<< change this value to 2
```
```
---
apiVersion: anywhere.eks.amazonaws.com/v1alpha1
kind: VSphereMachineConfig
metadata:
  name: ambar01-wk
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
# SCENARIO-3 Data Protection using Dell's PPDM
* We will protect the EKS Anywhere cluster and the assets namely the namespaces "argocd" and "sock-shop"
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
* Create the protection policies for argocd and sock-shop
* Create the backup for these assets
* Delete the namespace of argocd and sock-shop
* Recover the namespace of argocd only
* Validate if argocd reinstates the resource state for sock-shop application via GitOps
* Although, ArgoCD has recreated sock-shop resources, there will be no data in the application
* Recover the sock-shop application state via PowerProtect restore
* Validate the sock-shop application
