```
kubectl create ns demo

kubectl create secret generic mysql-creds -n demo \
--from-literal=username=root \
--from-literal=password=fake_password

kubectl create secret generic mongodb-creds -n demo \
--from-literal=username=root \
--from-literal=password=fake_password

kubectl create configmap -n demo sockshop-catalogue-db-init-script \
--from-literal=init.sql="$(curl -fsSL https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/sock-shop/dump/catalog.sql)"

kubectl create configmap -n demo sockshop-userdb-init-script \
--from-literal=init.js="$(curl -fsSL https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/sock-shop/dump/user.js)"


cat <<EOF | kubectl apply -f -
apiVersion: kubedb.com/v1alpha2
kind: MySQL
metadata:
  name: catalogue-db
  namespace: demo
spec:
  version: "5.7.41"
  authSecret:
    name: mysql-creds
  topology:
    mode: GroupReplication
  replicas: 3
  storage:
    storageClassName: "powerstore-topology"
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
  init:
    script:
      configMap:
        name: sockshop-catalogue-db-init-script
  podTemplate:
    spec:
      nodeSelector:
        group: md-2
      env:
      - name: MYSQL_DATABASE
        value: socksdb
EOF


cat <<EOF | kubectl apply -f -
apiVersion: kubedb.com/v1alpha2
kind: MongoDB
metadata:
  name: user-db
  namespace: demo
spec:
  version: "4.2.3"
  authSecret:
    name: mongodb-creds
    externallyManaged: true
  replicaSet:
    name: "rs0"
  replicas: 3
  storageType: Durable
  storage:
    storageClassName: "powerstore-topology"
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
  init:
    script:
      configMap:
        name: sockshop-userdb-init-script
  podTemplate:
    spec:
      nodeSelector:
        group: md-2
EOF
```
