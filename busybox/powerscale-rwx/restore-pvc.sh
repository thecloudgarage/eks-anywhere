#!/bin/bash
read -p 'volumeSnapshotName: ' volumeSnapshotName
rm -rf $HOME/eks-anywhere/busybox/powerscale/restore-pvc.yaml
cp $HOME/eks-anywhere/busybox/powerscale/restore-pvc-sample.yaml \
        $HOME/eks-anywhere/busybox/powerscale/restore-pvc.yaml
sed -i "s/volumeSnapshotName/$volumeSnapshotName/g" \
        $HOME/eks-anywhere/busybox/powerscale/restore-pvc.yaml
kubectl create -f $HOME/eks-anywhere/busybox/powerscale/restore-pvc.yaml
