* Installs ArgoCD as a load balanced service without Ingress
* ArgoCD by default creates an internal SSL self-signed certificate

```
kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.4/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n argocd
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
* Login to ArgoCD
* Add the TLS certificate for the gitlab repository in PEM format
![image](https://user-images.githubusercontent.com/39495790/178540418-f10b6e5f-b05e-4290-b32c-b092df18eda2.png)

* Add a git repository
![image](https://user-images.githubusercontent.com/39495790/178540756-d096a2a8-dbd6-482c-9fd3-cff0a84d02c1.png)

* Add an application referencing the gitlab repository



