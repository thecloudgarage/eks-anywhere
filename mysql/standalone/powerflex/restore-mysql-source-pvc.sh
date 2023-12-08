read -p 'namespace for source snapshot and pvc to be restored: ' namespace
kubectl get volumesnapshot -n demo  -o 'jsonpath={.items[*].metadata.name}' |xargs -n1 basename
read -p 'provide name of snapshot to be restored from above list: '  volumeSnapshotName
kubectl delete -f mysql-source-cluster.yaml
kubectl delete -f mysql-restored-source-cluster.yaml
kubectl delete -f mysql-restored-pvc-source-cluster.yaml
rm -rf mysql-restored-pvc-source-cluster.yaml
rm -rf mysql-restored-pvc-source-cluster.yaml*
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/mysql-restored-pvc-source-cluster-sample.yaml
cp mysql-restored-pvc-source-cluster-sample.yaml mysql-restored-pvc-source-cluster.yaml
sed -i "s/volumeSnapshotName/$volumeSnapshotName/g" mysql-restored-pvc-source-cluster.yaml
sed -i "s/demo/$namespace/g" mysql-restored-pvc-source-cluster.yaml
kubectl create -f mysql-restored-pvc-source-cluster.yaml
kubectl create -f mysql-restored-source-cluster.yaml
