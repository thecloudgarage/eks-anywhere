* Open windows cmd and change path to the directory where argocd is installed
* Export the required variables
```
set GITLAB_HOST="gitlab.oidc.thecloudgarage.com"
set GITLAB_PROJECT="https://gitlab.oidc.thecloudgarage.com:10443/ambarhassani/gitops-argocd-eksa.git"
set GITLAB_PROJECT_TOKEN=glpat-59Un7Nf1Us2pskZ_jxsu
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
argocd app create eksa-cluster-testcluster --repo %GITLAB_PROJECT% --path clusters/testcluster --dest-server https://kubernetes.default.svc --directory-recurse --sync-policy none
```
