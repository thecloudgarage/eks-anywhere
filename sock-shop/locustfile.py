import base64
import time
from locust import HttpUser, TaskSet, task, between
from random import randint, choice

class WebsiteUser(HttpUser):
    wait_time = between(1, 5)

    @task(1)
    def on_start(self):
        self.client.verify = False
    @task(2)
    def get_index(self):
        base64string = base64.encodebytes(('%s:%s' % ('user', 'password')).encode()).decode().strip()
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
