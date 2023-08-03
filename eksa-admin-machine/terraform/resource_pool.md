* If a resource pool is not created or you don't have permissions to create
* Then the value of resource pool in the variables.tf will be Cluster/Resources (e.g. in my case the DC is IAC-SSC and cluster is IAC), so the value will be IAC/Resources

![image](https://github.com/thecloudgarage/eks-anywhere/assets/39495790/87f29861-1ec4-4884-acdc-a017651b6b99)

* Other than this, the value of the resource pool in the vsphere-connection.json and in the cluster-samples have to kept as /Datacentername/host/clustername/Resources Example /IAC-SSC/host/IAC/Resources
