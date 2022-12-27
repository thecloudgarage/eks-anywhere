#!/bin/bash
NOW=$(date "+%Y%m%d%H%M%S")
rm -rf $HOME/eks-anywhere/busybox/powerscale/snapshot.yaml
cp $HOME/eks-anywhere/busybox/powerscale/snapshot-sample.yaml \
        $HOME/eks-anywhere/busybox/powerscale/snapshot.yaml
sed -i "s/datetime/$NOW/g" $HOME/eks-anywhere/busybox/powerscale/snapshot.yaml
kubectl create -f $HOME/eks-anywhere/busybox/powerscale/snapshot.yaml
