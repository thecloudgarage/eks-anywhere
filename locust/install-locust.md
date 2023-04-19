### Install locust on Kubernetes
```
helm upgrade --install locust deliveryhero/locust \
 --set loadtest.name=eks-loadtest \
 --set loadtest.locust_locustfile_configmap=eks-loadtest-locustfile \
 --set loadtest.locust_locustfile=locustfile.py
```
### Create the Ingress resource
```
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-locust
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  defaultBackend:
    service:
      name: locust
      port:
        number: 8089
EOF
```
