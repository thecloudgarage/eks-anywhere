#### IMP NOTE
* We will be using the EKSA Admin machine to host the Harbor docker instance for proxy-caching
* Ensure that the DNS entry is created for the harbor FQDN before hand (e.g. harbor.oidc.thecloudgarage.com)
* In this saga series, we will use a common wildcard certificate including for harbor

#### INSTALL HARBOR VIA DOCKER-COMPOSE
* Login to the EKS Anywhere admin machine as user "ubuntu"
* Create a ssl conf file under directory named common-certs
```
mkdir -p $HOME/common-certs
cat <<EOF > $HOME/common-certs/sslcert.conf
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = IN
ST = MH
L = Mumbai
O = stack
OU = devops
CN = *.oidc.thecloudgarage.com
[v3_req]
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = thecloudgarage.com
DNS.2 = *.thecloudgarage.com
DNS.3 = *.oidc.thecloudgarage.com
EOF
```
* Generate the wild card certificate
```
cd $HOME/common-certs
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout tls.key -out tls.crt -config sslcert.conf -extensions 'v3_req'
```
* For EKS Anywhere to create clusters with proxy-cache, export the below variable in the ubuntu profile
```
echo "EKSA_REGISTRY_MIRROR_CA=/home/ubuntu/common-certs/tls.crt; export EKSA_REGISTRY_MIRROR_CA" >> ~/.profile
source ~/.profile
```
#### FROM HEREON, SWITCH TO ROOT USER
```
sudo su
cd /home/ubuntu/common-certs
export HARBOR_FQDN=harbor.oidc.thecloudgarage.com
```
* Add the harbor wildcard certificate for docker daemon on the EKS Anywhere admin machine
```
mkdir -p /etc/docker/certs.d/$HARBOR_FQDN
cp ./tls.crt /etc/docker/certs.d/$HARBOR_FQDN
cp ./tls.key /etc/docker/certs.d/$HARBOR_FQDN
cd /etc/docker/certs.d/$HARBOR_FQDN
ls -al
systemctl restart docker
```
* Download offline installer for Harbor
cd /home/ubuntu
wget https://github.com/goharbor/harbor/releases/download/v2.8.1/harbor-offline-installer-v2.8.1.tgz
tar xvzf harbor-offline-installer*.tgz
cd /home/ubuntu/harbor
cp harbor.yml.tmpl harbor.yml
```
* Edit the harbor.yml and change only the details mentioned herein
```
hostname: harbor.oidc.thecloudgarage.com
certificate: /home/ubuntu/common-certs/harbor.oidc.thecloudgarage.com.crt
private_key: /home/ubuntu/common-certs/harbor.oidc.thecloudgarage.com.key
Under trivy... set insecure to false
```
* Install Harbor
```
cd /home/ubuntu/harbor
./install.sh
docker-compose down
```
* This hack is required else, no registry endpoints can be pinged from the container
sed -i '/dns/d' docker-compose.yml
docker-compose up -d
docker ps and observe if all containers are working fine
```
* Login to Harbor and create proxy-cache registry end points
- docker-hub with the selectable as Docker Hub
- gcr-io with the selectable as Docker registry and URL as https://gcr.io
- k8s-gcr-io with the selectable as Docker registry and URL as https://k8s.gcr.io
- quay-io with the selectable as Docker registry and URL as https://quay.io
* Create the following projects as proxy-cache and set them as public
- proxy.docker.io (select the registry end point as docker-hub
- proxy.gcr.io (select the registry end point as gcr-io)
- proxy.k8s.gcr.io (select the registry end point as k8s-gcr-io)
- proxy.quay.io (select the registry end point as quay-io)
