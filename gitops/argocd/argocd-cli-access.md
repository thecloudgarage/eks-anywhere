Download ArgoCD CLI on windows
```
https://github.com/argoproj/argo-cd/releases
Download the .exe file
Rename the file to argocd.exe
Adjust path variables if required or create a folder and place the file into it
```
For Linux
```
VERSION=<TAG> # Select desired TAG from https://github.com/argoproj/argo-cd/releases
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```
For regular logins
```
cd to path
argocd login <FQDN-of-ArgoCD>
```
For OIDC logins
```
argocd login <FQDN-of-ArgoCD> --sso
```
