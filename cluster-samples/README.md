# Standalone Workload clusters
```
CLUSTER_NAME=<cluster-name>
API_SERVER_IP=<ip-address>
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
```

# Management clusters
```
CLUSTER_NAME=<cluster-name>
API_SERVER_IP=<ip-address>
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
```

# Workload clusters managed via a dedicated management cluster
```
CLUSTER_NAME=<cluster-name>
MGMT_CLUSTER_NAME=<mgmt-cluster-name>
API_SERVER_IP=<ip-address>
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$MGMT_CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
```
# Cluster template structure

##KEY NOTES
One can observe that the main cluster CRD identified by the resource type cluster leverages other CRDs for various configuration references. The static terms will need to be changed along with other specific vSphere related parameters
* workload-cluster-name
* management-cluster-name
* api-server-ip

Other parameters for size and configuration can be accordingly tuned for various node groups
![image](https://user-images.githubusercontent.com/39495790/190468100-53276382-c15b-46b3-a8cd-ce04b1120be9.png)

![clustersample](https://user-images.githubusercontent.com/39495790/190064228-99a974d8-6313-427e-a048-a8be61a7d298.png)
