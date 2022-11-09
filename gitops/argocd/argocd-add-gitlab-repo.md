export GITLAB_HOST="gitlab.oidc.thecloudgarage.com"
export GITLAB_PROJECT="https://gitlab.oidc.thecloudgarage.com:10443/ambarhassani/gitops-argocd-eksa.git"
export GITLAB_PROJECT_TOKEN=glpat-59Un7Nf1Us2pskZ_jxsu
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
