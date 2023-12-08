#!/bin/bash
read -p 'volumeSnapshotName: ' volumeSnapshotName
rm -rf restore-mysql-source-pvc-sample.yaml
rm -rf restore-mysql-source-pvc.ya*
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/restore-mysql-source-pvc-sample.yaml
cp restore-mysql-source-pvc-sample.yaml restore-mysql-source-pvc.yaml
sed -i "s/volumeSnapshotName/$volumeSnapshotName/g" restore-mysql-source-pvc.yaml
kubectl create -f restore-mysql-source-pvc.yaml
