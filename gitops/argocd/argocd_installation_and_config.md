### Pre-requisites
* Ensure MetalLB is installed and configured before hand
* KeyCloak is setup for ArgoCD web and CLI client that uses grpc
### Perform the below procedure on the EKS Anywhere admin machine
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
    url: https://argocd.oidc.thecloudgarage.com
    application.instanceLabelKey: argocd.argoproj.io/instance
    admin.enabled: 'true'
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
* Get the External IP and create a DNS entry
* Next install the argocd CLI on the EKS Anywhere admin machine
```
VERSION=<TAG> # Select desired TAG from https://github.com/argoproj/argo-cd/releases
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```
* Since ArgoCD is being authenticated via OIDC, it will open a browser for KeyCloak authentication
* This cannot be done via putty or shell
* Login to the vSphere web client and open the web console for EKS Anywhere admin machine
* The EKS Anywhere admin machine is a ubuntu desktop image with firefox loaded
* Once into the web console of the EKS Anywhere admin machine, open the cmd terminal and type the below
* Please note that FQDN:443 should not consist of https:// ... just the hostname and port is enough. Example: argocdtest.oidc.thecloudgarage.com:443
```
argcod login <FQDN:443> --sso
```
* Accept certificate warning
* It will open up a browser window in FireFox to authenticate
* If one has followed the KeyCloak installation as a part of the saga series, then a user named user-admin along with password as user-admin is already created
* We will use this as the login credentials
* Once logged in via the web console cmd argocd cli, we can use the same logged in session via the putty
* Switch back to the putty session to the EKS Anywhere admin machine and continue executing argocd commands

### Connect with a Gitlab host
* We will be using GitLab as a source system in the saga series
* First act in the ArgoCD setup will be to connect to this GitLab system
* In my case, the GitLab is available via a HTTPS self signed certificate and is running on port 10443
* Let's observe how we add the self signed cert for this GitLab source
* While on the EKS Anywhere Admin machine and logged in via ArgoCD CLI
```
GITLAB_HOST="gitlab.oidc.thecloudgarage.com"
sudo echo -n | openssl s_client -connect $GITLAB_HOST:10443 -servername $GITLAB_HOST | openssl x509 > $HOME/$GITLAB_HOST.crt
argocd cert add-tls --from $HOME/$GITLAB_HOST.crt $GITLAB_HOST
```
* This will add the GitLab's self signed certificate in the argoCD system such that it will not create errors
