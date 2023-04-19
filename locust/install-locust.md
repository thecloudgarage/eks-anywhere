### Create a sample locust file. Note the use self.client.verify to disable SSL verification... use it for self-signed certificates
```
cat <<EOF > locustfile.py && cat locustfile.py
import time
from locust import HttpUser, TaskSet, task, between

class WebsiteUser(HttpUser):
    wait_time = between(1, 5)

    @task(1)
    def on_start(self):
        self.client.verify = False
    @task(2)
    def get_index(self):
        self.client.get("/category.html")
EOF
```

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
