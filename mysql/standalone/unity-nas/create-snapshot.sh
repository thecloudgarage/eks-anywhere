#!/bin/bash
NOW=$(date "+%Y%m%d%H%M%S")
rm -rf snapshot.yaml
cp snapshot-sample.yaml snapshot.yaml
sed -i "s/datetime/$NOW/g" snapshot.yaml
kubectl create -f snapshot.yaml
