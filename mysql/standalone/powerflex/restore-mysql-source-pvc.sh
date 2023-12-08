read -p 'namespace for source snapshot and pvc to be restored: ' namespace
kubectl get volumesnapshot -n demo  -o 'jsonpath={.items[*].metadata.name}' |xargs -n1 basename
read -p 'provide name of snapshot to be restored from above list: '  volumeSnapshotName
rm -rf restore-mysql-source-pvc-sample.yaml
rm -rf restore-mysql-source-pvc.ya*
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/restore-mysql-source-pvc-sample.yaml
cp restore-mysql-source-pvc-sample.yaml restore-mysql-source-pvc.yaml
sed -i "s/volumeSnapshotName/$volumeSnapshotName/g" restore-mysql-source-pvc.yaml
sed -i "s/demo/$namespace/g" restore-mysql-source-pvc.yaml
kubectl create -f restore-mysql-source-pvc.yaml
