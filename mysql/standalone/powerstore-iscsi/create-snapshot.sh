#!/bin/bash
NOW=$(date "+%Y%m%d%H%M%S")
rm -rf $HOME/eks-anywhere/mysql/standalone/powerstore-iscsi/snapshot.yaml
cp $HOME/eks-anywhere/mysql/standalone/powerstore-iscsi/snapshot-sample.yaml \
        $HOME/eks-anywhere/mysql/standalone/powerstore-iscsi/snapshot.yaml
sed -i "s/datetime/$NOW/g" $HOME/eks-anywhere/mysql/standalone/powerstore-iscsi/snapshot.yaml
kubectl create -f $HOME/eks-anywhere/mysql/standalone/powerstore-iscsi/snapshot.yaml

