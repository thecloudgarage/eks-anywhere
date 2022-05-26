#!/bin/bash
read -p 'volumeSnapshotName: ' volumeSnapshotName
rm -rf restore-pvc.yaml
cp restore-pvc-sample.yaml restore-pvc.yaml
sed -i "s/volumeSnapshotName/$volumeSnapshotName/g" restore-pvc.yaml
kubectl create -f restore-pvc.yaml
