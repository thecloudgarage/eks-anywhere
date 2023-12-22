Create the YAML for Locust config map
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

kubectl create configmap sockshop-locust-configmap -n sock-shop --from-file ./locustfile.py --dry-run=client --output=yaml > cm-locust.yaml
```
Create the YAML for Locust deployment
```
helm template locust deliveryhero/locust \
--set loadtest.name=loadtest  \
--set loadtest.locust_locustfile_configmap=sockshop-locust-configmap  \
--set loadtest.locust_locustfile=locustfile.py \
--set worker.resources.requests.cpu=500m \
--set worker.resources.requests.memory=512Mi \
--set nodeSelector."group"="md-2" \
--set worker.hpa.enabled=true \
--set worker.hpa.minReplicas=5 \
--set worker.hpa.targetCPUUtilizationPercentage=70 | kubectl apply -f - --namespace sock-shop --dry-run=client --output=yaml > install-locust-sockshop.yaml
```
