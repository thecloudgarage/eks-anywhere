Export the required variables
```
export GITLAB_HOST="gitlab.oidc.thecloudgarage.com"
export GITLAB_PROJECT="https://gitlab.oidc.thecloudgarage.com:10443/ambarhassani/gitops-argocd-eksa.git"
export GITLAB_PROJECT_TOKEN=glpat-59Un7Nf1Us2pskZ_jxsu
```
Add the TLS certificate
```
sudo echo -n | openssl s_client -connect $GITLAB_HOST:10443 -servername $GITLAB_HOST \
| openssl x509 > $HOME/$GITLAB_HOST.pem
argocd cert add-tls --from $HOME/$GITLAB_HOST.pem $GITLAB_HOST
```
Add the Repository
```
argocd repo add $GITLAB_PROJECT --username git --password $GITLAB_PROJECT_TOKEN --insecure-skip-server-verification
```
Add the Application Sockshop
```
argocd app create guestbook --repo $GITLAB_PROJECT --path applications/sockshop --dest-server https://kubernetes.default.svc --directory-recurse --sync-policy none
```
Add the Application for EKS Anywhere cluster management
```
argocd app create guestbook --repo $GITLAB_PROJECT --path clusters --dest-server https://kubernetes.default.svc --directory-recurse --sync-policy none
```
