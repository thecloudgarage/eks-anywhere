Download ArgoCD CLI on windows
```
https://github.com/argoproj/argo-cd/releases
Download the .exe file
Rename the file to argocd.exe
Adjust path variables if required or create a folder and place the file into it
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
