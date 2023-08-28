Example for Sock Shop application. Ensure that Ingress controller and MetalLB load balancer is set before hand. Also ensure that the cluster is created with Nodegroups (e.g. md-0) which will be used to deploy resource intensive pods of locust workers

### Create a sample locust file. Note the use self.client.verify to disable SSL verification... use it for self-signed certificates
```
cat <<EOF > locustfile.py && cat locustfile.py
import base64
import time
from locust import HttpUser, TaskSet, task, between, FastHttpUser
from random import randint, choice

class WebsiteUser(HttpUser):
    wait_time = between(1, 2.5)
    @task
    def on_start(self):
        self.client.verify = False
    @task
    def get_index(self):
        base64string = base64.encodebytes(('%s:%s' % ('ambar', 'Test@1234')).encode()).decode().strip()
        catalogue = self.client.get("/catalogue").json()
        category_item = choice(catalogue)
        item_id = category_item["id"]
        self.client.get("/")
        self.client.get("/login", headers={"Authorization":"Basic %s" % base64string})
        self.client.get("/category.html")
        self.client.get("/detail.html?id={}".format(item_id))
        self.client.delete("/cart")
        self.client.post("/cart", json={"id": item_id, "quantity": 1})
        self.client.get("/basket.html")
        self.client.post("/orders")
EOF
```
## NOTE: ALl locust resources are being created in default namespace.
### Create a configmap 
```
kubectl create configmap sockshop-loadtest-locustfile --from-file ./locustfile.py
```

### Install locust on Kubernetes with a distributed worker model with support for Node groups
Advanced with HPA and node selector
```
helm repo add deliveryhero https://charts.deliveryhero.io/
helm repo update
helm upgrade --install locust deliveryhero/locust  \
--set loadtest.name=loadtest  \
--set loadtest.locust_locustfile_configmap=locust-configmap  \
--set loadtest.locust_locustfile=locustfile.py \
--set worker.resources.requests.cpu=500m \
--set worker.resources.requests.memory=512Mi \
--set nodeSelector."group"="md-1" \
--set worker.hpa.enabled=true \
--set worker.hpa.minReplicas=5 \
--set worker.hpa.targetCPUUtilizationPercentage=70
```
Alternatively to generate a YAML template
```
helm template locust deliveryhero/locust  \
--set loadtest.name=loadtest  \
--set loadtest.locust_locustfile_configmap=locust-configmap  \
--set loadtest.locust_locustfile=locustfile.py \
--set worker.resources.requests.cpu=500m \
--set worker.resources.requests.memory=512Mi \
--set nodeSelector."group"="md-1" \
--set worker.hpa.enabled=true \
--set worker.hpa.minReplicas=5 \
--set worker.hpa.targetCPUUtilizationPercentage=70 \
> locust-helm-default-namespace.yaml
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
