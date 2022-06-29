#!/bin/bash
read -p 'volumeSnapshotName: ' volumeSnapshotName
rm -rf $HOME/eks-anywhere/mysql/standalone/powerstore-iscsi/restore-pvc.yaml
cp $HOME/eks-anywhere/mysql/standalone/powerstore-iscsi/restore-pvc-sample.yaml \
        $HOME/eks-anywhere/mysql/standalone/powerstore-iscsi/restore-pvc.yaml
sed -i "s/volumeSnapshotName/$volumeSnapshotName/g" \
        $HOME/eks-anywhere/mysql/standalone/powerstore-iscsi/restore-pvc.yaml
kubectl create -f $HOME/eks-anywhere/mysql/standalone/powerstore-iscsi/restore-pvc.yaml

