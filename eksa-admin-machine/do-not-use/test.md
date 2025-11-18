### EKSA Admin machine (ubuntu user)
Export variables
```
export vsphere_server="vcenter01.demo.local"
export vsphere_user=""
export vsphere_password=""
export vsphere_datastore="nfs-datastore"
export vsphere_datacenter=""
export vsphere_compute_cluster="cluster"
export virtual_machine_root_password=""
export vsphere_templates_folder="Templates"
export vsphere_resource_pool="eksa"
export vsphere_network="VLAN0-prod-vm-network"
```
Bootstrap
```
sudo apt-get update -y
sudo apt install git -y
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512
#
cd $HOME && git clone https://github.com/thecloudgarage/eks-anywhere.git
find $HOME/eks-anywhere/ -name "*.sh" -type f -print0 | xargs -0 chmod +x
cp $HOME/eks-anywhere/cluster-ops/*.sh $HOME/
#
sed -i '/^EKSA_VSPHERE_/d' ~/.profile
echo "EKSA_VSPHERE_USERNAME=$vsphere_user; export EKSA_VSPHERE_USERNAME" >> ~/.profile
echo "EKSA_VSPHERE_PASSWORD=$vsphere_password; export EKSA_VSPHERE_PASSWORD" >> ~/.profile
#
echo "vsphere_server=$vsphere_server; export vsphere_server" >> ~/.profile
echo "vsphere_user=$vsphere_user; export vsphere_user" >> ~/.profile
echo "vsphere_password=$vsphere_password; export vsphere_password" >> ~/.profile
echo "vsphere_datacenter=$vsphere_datacenter; export vsphere_datacenter" >> ~/.profile
echo "vsphere_compute_cluster=$vsphere_compute_cluster; export vsphere_compute_cluster" >> ~/.profile
echo "vsphere_datastore=$vsphere_datastore; export vsphere_datastore" >> ~/.profile
echo "vsphere_network=$vsphere_server; export vsphere_network" >> ~/.profile
echo "vsphere_templates_folder=$vsphere_templates_folder; export vsphere_templates_folder" >> ~/.profile
echo "vsphere_resource_pool=$vsphere_resource_pool; export vsphere_resource_pool" >> ~/.profile
#
sudo adduser --gecos "" --disabled-password image-builder
sudo chpasswd <<<image-builder:$virtual_machine_root_password
sudo usermod -aG sudo image-builder
#
sudo apt-get update -y
sudo apt-get install git build-essential procps curl file git zip unzip sshpass jq apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo -e "" | sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo usermod -aG docker $USER
wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
chmod +x install.sh
#NOTE HOW WE ARE PASSING AN ENTER FOR THE INTERACTIVE PROMPT THAT THE INSTALL SCRIPT GENERATES TO CONFIRM FOR INSTALLATION
sudo echo -ne '\n' | ./install.sh
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#
sleep 20
brew install aws/tap/eks-anywhere
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew install argocd
brew install fluxcd/tap/flux
brew install kustomize
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```
### EKSA Admin machine (image-builder user)
Export variables
```
export vsphere_server="vcenter01.demo.local"
export vsphere_user=""
export vsphere_password=""
export vsphere_datastore="nfs-datastore"
export vsphere_datacenter=""
export vsphere_compute_cluster="cluster"
export virtual_machine_root_password=""
export vsphere_templates_folder="Templates"
export vsphere_resource_pool="eksa"
export vsphere_network="VLAN0-prod-vm-network"
#
```
Bootstrap
```
echo $virtual_machine_root_password | sudo -S ls
cd /home/image-builder
echo "GOVC_URL=$vsphere_server; export GOVC_URL" >> ~/.profile
echo "GOVC_USERNAME=$vsphere_user; export GOVC_USERNAME" >> ~/.profile
echo "GOVC_PASSWORD=$vsphere_password; export GOVC_PASSWORD" >> ~/.profile
echo "GOVC_INSECURE=true; export GOVC_INSECURE" >> ~/.profile
echo "GOVC_DATASTORE=$vsphere_datastore; export GOVC_DATASTORE" >> ~/.profile
echo "GOVC_DATACENTER=$vsphere_datacenter; export GOVC_DATACENTER" >> ~/.profile
echo "EKSA_SKIP_VALIDATE_DEPENDENCIES=true; export EKSA_SKIP_VALIDATE_DEPENDENCIES" >> ~/.profile
#
sudo apt-get update -y
sudo apt-get install git build-essential procps curl file git zip unzip sshpass jq apt-transport-https ca-certificates curl software-properties-common python3 python3-setuptools python3-dev python3-pip -y
sudo snap install yq
#
git clone https://github.com/thecloudgarage/eks-anywhere.git
find $HOME/eks-anywhere/ -name "*.sh" -type f -print0 | xargs -0 chmod +x
cp $HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/vsphere-connection.json $HOME/vsphere-connection.json
echo $virtual_machine_root_password | sudo -S apt-get update -y
#
mkdir -p /home/image-builder/.ssh
sudo mkdir -p /tmp/eks-image-builder-cni
sudo chown -R image-builder:image-builder /tmp/eks-image-builder-cni
#
echo -e "\n" sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install python3.9 -y
echo -e "\n" | sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
echo -e "\n" | sudo update-alternatives --config python3
python3 -m pip install --user ansible
#
echo "HostKeyAlgorithms +ssh-rsa" >> /home/image-builder/.ssh/config
echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /home/image-builder/.ssh/config
sudo chmod 600 /home/image-builder/.ssh/config
#
sudo curl -L -o - https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz | sudo tar -C /usr/local/bin -xvzf - govc
export EKSA_RELEASE_VERSION=$(curl -sL https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml | yq ".spec.latestVersion")
export BUNDLE_MANIFEST_URL=$(curl -s https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml | yq ".spec.releases[] | select(.version==\"$EKSA_RELEASE_VERSION\").bundleManifestUrl")
export IMAGEBUILDER_TARBALL_URI=$(curl -s $BUNDLE_MANIFEST_URL | yq ".spec.versionsBundles[0].eksD.imagebuilder.uri")
echo $EKSA_RELEASE_VERSION > /home/image-builder/eksa_release_version.txt
echo $BUNDLE_MANIFEST_URL > /home/image-builder/bundle_manifest_url.txt
echo $IMAGEBUILDER_TARBALL_URI > /home/image-builder/imagebuilder-tarball-uri.txt
sudo curl -s $IMAGEBUILDER_TARBALL_URI | sudo tar xz ./image-builder
sudo cp image-builder /usr/local/bin
cd -
#
sed -i "s/vsphere_compute_cluster/$vsphere_compute_cluster/g" $HOME/vsphere-connection.json
sed -i "s/vsphere_datacenter/$vsphere_datacenter/g" $HOME/vsphere-connection.json
sed -i "s/vsphere_datastore/$vsphere_datastore/g" $HOME/vsphere-connection.json
sed -i "s/vsphere_templates_folder/$vsphere_templates_folder/g" $HOME/vsphere-connection.json
sed -i "s/vsphere_network/$vsphere_network/g" $HOME/vsphere-connection.json
sed -i "s/vsphere_password/$vsphere_password/g" $HOME/vsphere-connection.json
sed -i "s/vsphere_resource_pool/$vsphere_resource_pool/g" $HOME/vsphere-connection.json
sed -i "s/vsphere_user/$vsphere_user/g" $HOME/vsphere-connection.json
sed -i "s/vsphere_server/$vsphere_server/g" $HOME/vsphere-connection.json
cp $HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/ubuntu_node_template* $HOME/
```
### Sample cluster template
```
apiVersion: anywhere.eks.amazonaws.com/v1alpha1
kind: Cluster
metadata:
 name: workload-cluster-name
spec:
  clusterNetwork:
    cni: cilium
    pods:
      cidrBlocks:
      - 172.16.0.0/16
    services:
      cidrBlocks:
      - 10.96.0.0/12
  controlPlaneConfiguration:
    count: 2
    endpoint:
      host: "192.168.1.100"
    machineGroupRef:
      kind: VSphereMachineConfig
      name: workload-cluster-name-cp
  datacenterRef:
    kind: VSphereDatacenterConfig
    name: workload-cluster-name-dcconfig
  externalEtcdConfiguration:
    count: 3
    machineGroupRef:
      kind: VSphereMachineConfig
      name: workload-cluster-name-etcd
  kubernetesVersion: "1.21"
  managementCluster:
    name: management-cluster-name
  workerNodeGroupConfigurations:
  - count: 2
    machineGroupRef:
      kind: VSphereMachineConfig
      name: workload-cluster-name-wk
    name: md-0

---
apiVersion: anywhere.eks.amazonaws.com/v1alpha1
kind: VSphereDatacenterConfig
metadata:
  name: workload-cluster-name-dcconfig
spec:
  datacenter: "democenter"
  insecure: true
  network: "VLAN0-prod-vm-network"
  server: "vcenter01.demo.local"
  thumbprint: "F7:A3:92:55:2D:73:B1:BA:1C:77:A8:AC:A3:AD:F3:62:8A:E0:53:CE"

---
apiVersion: anywhere.eks.amazonaws.com/v1alpha1
kind: VSphereMachineConfig
metadata:
  name: workload-cluster-name-cp
spec:
  datastore: "nfs-datastore"
#  diskGiB: 25
#  cloneMode: "fullClone"
  folder: "eksa"
  memoryMiB: 8192
  numCPUs: 4
  osFamily: ubuntu
  template: "ubuntu-2004-kube-v1.21"
  resourcePool: "eksa"
  users:
  - name: capv
    sshAuthorizedKeys:
    - ""

---
apiVersion: anywhere.eks.amazonaws.com/v1alpha1
kind: VSphereMachineConfig
metadata:
  name: workload-cluster-name-wk
spec:
  datastore: "nfs-datastore"
#  diskGiB: 25
#  cloneMode: "fullClone"
  folder: "eksa"
  memoryMiB: 8192
  numCPUs: 4
  osFamily: ubuntu
  template: "ubuntu-2004-kube-v1.21"
  resourcePool: "eksa"
  users:
  - name: capv
    sshAuthorizedKeys:
    - ""

---
apiVersion: anywhere.eks.amazonaws.com/v1alpha1
kind: VSphereMachineConfig
metadata:
  name: workload-cluster-name-etcd
spec:
  datastore: "nfs-datastore"
#  diskGiB: 25
#  cloneMode: "fullClone"
  folder: "eksa"
  memoryMiB: 8192
  numCPUs: 4
  osFamily: ubuntu
  template: "ubuntu-2004-kube-v1.31"
  resourcePool: "eksa"
  users:
  - name: capv
    sshAuthorizedKeys:
    - ""

---
Install MetalLB
```
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb --wait --timeout 15m --namespace metallb-system --create-namespace
```
Configure MetalLB
```
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.200-192.168.1.201
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF
```
NGINX Ingress Controller
```
kubectl apply -f https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/refs/heads/main/ingress-controllers/nginx-ingress-controller.yaml
```
Sample Ingress Enabled App
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: hello-world
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: hello-world
  name: hello-world
  namespace: hello-world
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
#      - image: gcr.io/google-samples/node-hello:1.0
      - image: us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
        name: hello-world
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world
  namespace: hello-world
spec:
  selector:
    app: hello-world
  ports:
    - port: 80
      targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: hello-world
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: "/hello-world"
        backend:
          service:
            name: hello-world
            port:
              number: 80
EOF 
```
