* Installs ArgoCD as a load balanced service without Ingress
* ArgoCD by default creates an internal SSL self-signed certificate
* For the purpose of this example (i.e. managing EKS A clusters) create the git repository upfront and create a project deployment token within the repository > settings > access tokens. This token will be used as a password along with the username "git" to connect from ArgoCD

```
kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.4/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n argocd
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
* Login to ArgoCD
* Copy the contents of the Gitlab server. The TLS certificate content was created during the creation of the Gitlab server and will be located in $HOME/eks-anywhere/gitops/gitlab/oidc-https and saved as the gitlab hostname crt file

![image](https://user-images.githubusercontent.com/39495790/178545230-edb25578-4099-4e76-bd1f-dc718fefa026.png)

* Create a git repository to connect to using https

![image](https://user-images.githubusercontent.com/39495790/178546138-5b075f35-1c6c-4e57-aa10-2be676de77a7.png)

The username will be git and the password will be the deploy token

![image](https://user-images.githubusercontent.com/39495790/178546394-3cc476a7-3604-4f8b-9899-4815957be635.png)

![image](https://user-images.githubusercontent.com/39495790/178546616-40f4a72e-f2da-4116-944e-cfa7083d0cbb.png)



![image](https://user-images.githubusercontent.com/39495790/178545622-d85afc18-c4bd-42b2-9623-4794dddd30d4.png)
![image](https://user-images.githubusercontent.com/39495790/178545885-440171f9-a6d5-48ae-9f38-d04f49797ab1.png)


![image](https://user-images.githubusercontent.com/39495790/178544246-0758fa00-06c8-4349-a2c1-37aa17348247.png)




* Add the TLS certificate for the gitlab repository in PEM format
![image](https://user-images.githubusercontent.com/39495790/178540418-f10b6e5f-b05e-4290-b32c-b092df18eda2.png)

* Add a git repository
![image](https://user-images.githubusercontent.com/39495790/178540756-d096a2a8-dbd6-482c-9fd3-cff0a84d02c1.png)

* Add an application referencing the gitlab repository



