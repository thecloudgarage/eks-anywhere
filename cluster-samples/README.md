# Cluster template structure
One can observe that the main cluster CRD (kind: cluster) leverages other CRDs (VSphereDatacenterConfig, VSphereMachineConfig). The co-relation is done via the name binding between the main block and the sub-blocks

![clustersample](https://user-images.githubusercontent.com/39495790/190472432-0da9ec8e-0434-4280-8e27-3382ab8d0a22.png)

# Create a base template based on the provided cluster-sample.yaml file (Do not change this file name)
* Edit the values for the specific vSphere environment (datacenter name, network name, server name, thumbrrint) in **Data Center config block:** 
* Next, we will need to change the target configuration for Control, worker and etcd nodes in the respective machine config blocks. 
** Size of each node group
** vSphere specific configuration (Datastore, Folder name, Resource Pool, 
** Template name based on what was created during the ubuntu image build process
* Once this is done, one will have a base cluster template that can be reused

# To create clusters
Now that the base cluster template is in place., one can run the below set of commands depending on the type of cluster being created

## Standalone Workload clusters
```
CLUSTER_NAME=<cluster-name>
API_SERVER_IP=<ip-address>
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
```

## Management clusters
```
CLUSTER_NAME=<cluster-name>
API_SERVER_IP=<ip-address>
cd $HOME
cp $HOME/eks-anywhere/cluster-samples/cluster-sample.yaml $CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/workload-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/management-cluster-name/$CLUSTER_NAME/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
sed -i "s/api-server-ip/$API_SERVER_IP/g" $HOME/$CLUSTER_NAME-eks-a-cluster.yaml
```

## Workload clusters managed via a dedicated management cluster
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
