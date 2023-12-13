# To create the demo and showcase volume snapshots and restores
```
cd $CLUSTER_NAME
mkdir powerflex
cd powerflex
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/adminer.yaml
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/mysql-pvc-source-cluster.yaml
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/mysql-source-cluster.yaml
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/mysql-restored-source-cluster.yaml
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/dump.sql
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/create-snapshot.sh
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/restore-mysql-source-from-snapshot.sh
chmod +x *.sh
kubectl create -f adminer.yaml
kubectl create -f mysql-pvc-source-cluster.yaml
kubectl create -f mysql-source-cluster.yaml
kubectl get svc -n demo
# Login to adminer IP and create a new database. Execute SQL command with the content of the dump.sql
./create-snapshot.sh
# Drop the cars table in the database
./restore-mysql-source-from-snapshot.sh
# Observe the new PVC and SQL database restoral
```
