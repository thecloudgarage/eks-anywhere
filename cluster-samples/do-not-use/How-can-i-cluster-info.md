# The information is stored on the management cluster and as an example

```
kubectl get VSphereMachineTemplate -A
NAMESPACE     NAME                                            AGE
eksa-system   c4-eksa1-control-plane-template-1663136212042   19h
eksa-system   c4-eksa1-etcd-template-1663136212042            19h
eksa-system   c4-eksa1-md-0-1663136212044                     19h
```
And the details

```
ubuntu@ubuntu-virtual-machine:~$ kubectl describe VSphereMachineTemplate -A
Name:         c4-eksa1-control-plane-template-1663136212042
Namespace:    eksa-system
Labels:       <none>
Annotations:  <none>
API Version:  infrastructure.cluster.x-k8s.io/v1beta1
Kind:         VSphereMachineTemplate
Metadata:
  Creation Timestamp:  2022-09-14T06:25:53Z
  Generation:          1
  Managed Fields:
    API Version:  infrastructure.cluster.x-k8s.io/v1beta1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:ownerReferences:
          k:{"uid":"3aee6ef2-83d2-4982-9205-943cc36c988c"}:
            .:
            f:apiVersion:
            f:kind:
            f:name:
            f:uid:
    Manager:      manager
    Operation:    Update
    Time:         2022-09-14T06:18:54Z
    API Version:  infrastructure.cluster.x-k8s.io/v1beta1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .:
          f:kubectl.kubernetes.io/last-applied-configuration:
        f:ownerReferences:
          .:
          k:{"uid":"8d0b0750-df31-46c7-9a4f-fc033220f09f"}:
            .:
            f:apiVersion:
            f:kind:
            f:name:
            f:uid:
      f:spec:
        .:
        f:template:
          .:
          f:spec:
            .:
            f:cloneMode:
            f:datacenter:
            f:datastore:
            f:diskGiB:
            f:folder:
            f:memoryMiB:
            f:network:
              .:
              f:devices:
            f:numCPUs:
            f:resourcePool:
            f:server:
            f:template:
            f:thumbprint:
    Manager:    clusterctl
    Operation:  Update
    Time:       2022-09-14T06:25:53Z
  Owner References:
    API Version:     cluster.x-k8s.io/v1beta1
    Kind:            Cluster
    Name:            c4-eksa1
    UID:             8d0b0750-df31-46c7-9a4f-fc033220f09f
  Resource Version:  2919
  UID:               15e4c9e2-3458-4592-9dfe-7ba03727562c
Spec:
  Template:
    Spec:
      Clone Mode:   linkedClone
      Datacenter:   IAC-SSC
      Datastore:    /IAC-SSC/datastore/CommonDS
      Disk Gi B:    25
      Folder:       /IAC-SSC/vm/test-eks-anywhere
      Memory Mi B:  8192
      Network:
        Devices:
          dhcp4:         true
          Network Name:  /IAC-SSC/network/iac_pg
      Num CP Us:         2
      Resource Pool:     /IAC-SSC/host/IAC/Resources/Test
      Server:            vc.iac.ssc
      Template:          /IAC-SSC/vm/Templates/ubuntu-v1.21.13-kubernetes-1-21-eks-16-amd64-219319d
      Thumbprint:
Events:                  <none>


Name:         c4-eksa1-etcd-template-1663136212042
Namespace:    eksa-system
Labels:       <none>
Annotations:  <none>
API Version:  infrastructure.cluster.x-k8s.io/v1beta1
Kind:         VSphereMachineTemplate
Metadata:
  Creation Timestamp:  2022-09-14T06:25:53Z
  Generation:          1
  Managed Fields:
    API Version:  infrastructure.cluster.x-k8s.io/v1beta1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:ownerReferences:
          k:{"uid":"3aee6ef2-83d2-4982-9205-943cc36c988c"}:
            .:
            f:apiVersion:
            f:kind:
            f:name:
            f:uid:
    Manager:      manager
    Operation:    Update
    Time:         2022-09-14T06:16:59Z
    API Version:  infrastructure.cluster.x-k8s.io/v1beta1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .:
          f:kubectl.kubernetes.io/last-applied-configuration:
        f:ownerReferences:
          .:
          k:{"uid":"8d0b0750-df31-46c7-9a4f-fc033220f09f"}:
            .:
            f:apiVersion:
            f:kind:
            f:name:
            f:uid:
      f:spec:
        .:
        f:template:
          .:
          f:spec:
            .:
            f:cloneMode:
            f:datacenter:
            f:datastore:
            f:diskGiB:
            f:folder:
            f:memoryMiB:
            f:network:
              .:
              f:devices:
            f:numCPUs:
            f:resourcePool:
            f:server:
            f:template:
            f:thumbprint:
    Manager:    clusterctl
    Operation:  Update
    Time:       2022-09-14T06:25:53Z
  Owner References:
    API Version:     cluster.x-k8s.io/v1beta1
    Kind:            Cluster
    Name:            c4-eksa1
    UID:             8d0b0750-df31-46c7-9a4f-fc033220f09f
  Resource Version:  2927
  UID:               0dbfdace-ede6-4a18-8ae6-e0deaa713899
Spec:
  Template:
    Spec:
      Clone Mode:   linkedClone
      Datacenter:   IAC-SSC
      Datastore:    /IAC-SSC/datastore/CommonDS
      Disk Gi B:    25
      Folder:       /IAC-SSC/vm/test-eks-anywhere
      Memory Mi B:  8192
      Network:
        Devices:
          dhcp4:         true
          Network Name:  /IAC-SSC/network/iac_pg
      Num CP Us:         2
      Resource Pool:     /IAC-SSC/host/IAC/Resources/Test
      Server:            vc.iac.ssc
      Template:          /IAC-SSC/vm/Templates/ubuntu-v1.21.13-kubernetes-1-21-eks-16-amd64-219319d
      Thumbprint:
Events:                  <none>


Name:         c4-eksa1-md-0-1663136212044
Namespace:    eksa-system
Labels:       <none>
Annotations:  <none>
API Version:  infrastructure.cluster.x-k8s.io/v1beta1
Kind:         VSphereMachineTemplate
Metadata:
  Creation Timestamp:  2022-09-14T06:25:52Z
  Generation:          1
  Managed Fields:
    API Version:  infrastructure.cluster.x-k8s.io/v1beta1
    Fields Type:  FieldsV1
    fieldsV1:
      f:spec:
        .:
        f:template:
          .:
          f:spec:
            .:
            f:cloneMode:
            f:datacenter:
            f:datastore:
            f:diskGiB:
            f:folder:
            f:memoryMiB:
            f:network:
              .:
              f:devices:
            f:numCPUs:
            f:resourcePool:
            f:server:
            f:template:
            f:thumbprint:
    Manager:      clusterctl
    Operation:    Update
    Time:         2022-09-14T06:25:52Z
    API Version:  infrastructure.cluster.x-k8s.io/v1beta1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:ownerReferences:
          .:
          k:{"uid":"3aee6ef2-83d2-4982-9205-943cc36c988c"}:
            .:
            f:apiVersion:
            f:kind:
            f:name:
            f:uid:
          k:{"uid":"8d0b0750-df31-46c7-9a4f-fc033220f09f"}:
            .:
            f:apiVersion:
            f:kind:
            f:name:
            f:uid:
    Manager:    manager
    Operation:  Update
    Time:       2022-09-14T16:22:15Z
  Owner References:
    API Version:     cluster.x-k8s.io/v1beta1
    Kind:            Cluster
    Name:            c4-eksa1
    UID:             8d0b0750-df31-46c7-9a4f-fc033220f09f
  Resource Version:  402012
  UID:               bc651099-f69c-43e6-9925-ae8b5deadf73
Spec:
  Template:
    Spec:
      Clone Mode:   linkedClone
      Datacenter:   IAC-SSC
      Datastore:    /IAC-SSC/datastore/CommonDS
      Disk Gi B:    25
      Folder:       /IAC-SSC/vm/test-eks-anywhere
      Memory Mi B:  8192
      Network:
        Devices:
          dhcp4:         true
          Network Name:  /IAC-SSC/network/iac_pg
      Num CP Us:         2
      Resource Pool:     /IAC-SSC/host/IAC/Resources/Test
      Server:            vc.iac.ssc
      Template:          /IAC-SSC/vm/Templates/ubuntu-v1.21.13-kubernetes-1-21-eks-16-amd64-219319d
      Thumbprint:
Events:                  <none>
```
OR
```
kubectl get VSphereDatacenterConfig
NAME                AGE
c4-eksa1-dcconfig   19h
```
And the details
```
ubuntu@ubuntu-virtual-machine:~$ kubectl describe VSphereDatacenterConfig
Name:         c4-eksa1-dcconfig
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  anywhere.eks.amazonaws.com/v1alpha1
Kind:         VSphereDatacenterConfig
Metadata:
  Creation Timestamp:  2022-09-14T06:26:31Z
  Generation:          1
  Managed Fields:
    API Version:  anywhere.eks.amazonaws.com/v1alpha1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .:
          f:kubectl.kubernetes.io/last-applied-configuration:
      f:spec:
        .:
        f:datacenter:
        f:insecure:
        f:network:
        f:server:
        f:thumbprint:
    Manager:         kubectl-client-side-apply
    Operation:       Update
    Time:            2022-09-14T06:26:31Z
  Resource Version:  3616
  UID:               60ec6a6b-9ee9-4f18-a7bc-049037fc7e61
Spec:
  Datacenter:  IAC-SSC
  Insecure:    true
  Network:     /IAC-SSC/network/iac_pg
  Server:      vc.iac.ssc
  Thumbprint:
Events:        <none>
```
