* Installs ArgoCD as a load balanced service without Ingress
* ArgoCD by default creates an internal SSL self-signed certificate

```
kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.4/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n argocd
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
* Login to ArgoCD

![image](https://user-images.githubusercontent.com/39495790/178545230-edb25578-4099-4e76-bd1f-dc718fefa026.png)

![image](https://user-images.githubusercontent.com/39495790/178546138-5b075f35-1c6c-4e57-aa10-2be676de77a7.png)

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



