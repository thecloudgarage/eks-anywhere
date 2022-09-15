# Cluster template structure

## KEY NOTES
* One can observe that the main cluster CRD identified by the resource type cluster leverages other CRDs for various configuration references. 

Other parameters for size and configuration can be accordingly tuned for various node groups

![clustersample](https://user-images.githubusercontent.com/39495790/190064228-99a974d8-6313-427e-a048-a8be61a7d298.png)

# What needs to be done 
* To start one needs to change the values for the specific vSphere environment needs to be set namely for the datacenter name, network name, server name, thumbrrint in Data Center config block
* Next, we will need to change the target configuration for Control, worker and etcd nodes. This includes size and specifications along with vSphere environment specific values
* Once this is done, one will have a base cluster template that can be reused for creating different types of clusters namely (standalone workload cluster, dedicated management cluster, workload clusters managed via a dedicated management cluster)
the below set of commands for each cluster type will reThe static terms will need to be changed along with other specific vSphere related parameters
* In order to faciliate the same, the below set of commands can be used as long as one does not change the sample cluster template name. The commands can be used depending on the type of cluster being created


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
