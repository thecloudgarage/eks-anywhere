#!/bin/bash
NOW=$(date "+%Y%m%d%H%M%S")
rm -rf $HOME/eks-anywhere/busybox/powerscale-rwx/snapshot.yaml
cp $HOME/eks-anywhere/busybox/powerscale-rwx/snapshot-sample.yaml \
        $HOME/eks-anywhere/busybox/powerscale-rwx/snapshot.yaml
sed -i "s/datetime/$NOW/g" $HOME/eks-anywhere/busybox/powerscale-rwx/snapshot.yaml
kubectl create -f $HOME/eks-anywhere/busybox/powerscale-rwx/snapshot.yaml
