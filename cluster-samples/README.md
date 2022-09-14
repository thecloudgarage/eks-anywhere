# Standalone Workload clusters
```
CLUSTER_NAME=<cluster-name>
API_SERVER_IP=<ip-address>
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME.yaml
sed "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME.yaml
sed "s/management-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME.yaml
sed "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME.yaml
```

# Management clusters
```
CLUSTER_NAME=<cluster-name>
API_SERVER_IP=<ip-address>
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME.yaml
sed "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME.yaml
sed "s/management-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME.yaml
sed "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME.yaml
```

# Workload clusters managed via a dedicated management cluster
```
CLUSTER_NAME=<cluster-name>
MGMT_CLUSTER_NAME=<mgmt-cluster-name>
API_SERVER_IP=<ip-address>
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME.yaml
sed "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME.yaml
sed "s/management-cluster-name/$MGMT_CLUSTER_NAME/g" $HOME/$CLUSTER_NAME.yaml
sed "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME.yaml
```

![clustersample](https://user-images.githubusercontent.com/39495790/190064228-99a974d8-6313-427e-a048-a8be61a7d298.png)
