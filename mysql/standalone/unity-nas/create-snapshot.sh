#!/bin/bash
NOW=$(date "+%Y%m%d%H%M%S")
rm -rf mysql-snapshot-unity-nas.yaml
cp mysql-snapshot-unity-nas-sample.yaml mysql-snapshot-unity-nas.yaml
sed -i "s/datetime/$NOW/g" mysql-snapshot-unity-nas.yaml
kubectl create -f mysql-snapshot-unity-nas.yaml
