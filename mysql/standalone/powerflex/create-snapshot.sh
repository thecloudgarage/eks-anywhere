#!/bin/bash
NOW=$(date "+%Y%m%d%H%M%S")
wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/mysql/standalone/powerflex/snapshot-sample.yaml
cp snapshot-sample.yaml snapshot.yaml
sed -i "s/datetime/$NOW/g" snapshot.yaml
kubectl create -f snapshot.yaml
