* Ensure that you have cloned the latest version of the EKS Anywhere GitHub repository associated with this saga series.
* SSH into the EKS Anywhere Administrative machine. Navigate to $HOME/eks-anywhere/cluster-samples/ sub-directory and edit the cluster-sample-nodepools-autoscaling.yaml file to reflect the vSphere environment as noted in the previous blogs.
* Copy the cluster creation script into the $HOME directory and make it executable.
```
cd $HOME
cp $HOME/eks-anywhere/cluster-ops/create-eksa-cluster-with-addons.sh .
chmod +x create-eksa-cluster-with-addons.sh
```
* Execute the script with adequate inputs as described in the previous blogs to create either a standalone workload cluster or a workload cluster managed via a dedicated management cluster.
```
cd $HOME
source create-eksa-cluster-with-addons.sh
```
* Example output:
```
source create-eksa-cluster-with-addons.sh
#######################IMPORTANT NOTE#################################
keep the name of workload and management cluster EXACTLY THE SAME
in case of creating standlone workload clusters or management clusters
######################################################################
Workload cluster name: c4-test1
Management cluster name: c4-test1
staticIp for API server High Availability: 172.24.165.11
#######################IMPORTANT NOTE#################################
Please copy the filename of the template intended for the cluster
######################################################################
cluster-sample-nodepools-autoscaling.yaml
cluster-sample.yaml
rj-cluster-sample.yaml
Cluster template filename: cluster-sample-nodepools-autoscaling.yaml
Kubernetes version 1.21, 1.22, v1.23, etc.: 1.23
Warning: VSphereDatacenterConfig configured in insecure mode
Performing setup and validations
Warning: VSphereDatacenterConfig configured in insecure mode
✅ Connected to server
✅ Authenticated to vSphere
✅ Datacenter validated
✅ Network validated
✅ Datastore validated
✅ Folder validated
✅ Resource pool validated
✅ Datastore validated
✅ Folder validated
✅ Resource pool validated
✅ Datastore validated
✅ Folder validated
✅ Resource pool validated
✅ Datastore validated
✅ Folder validated
✅ Resource pool validated
✅ Datastore validated
✅ Folder validated
✅ Resource pool validated
✅ Control plane and Workload templates validated
Provided control plane sshAuthorizedKey is not set or is empty, auto-generating new key pair...
Private key saved to c4-test1/eks-a-id_rsa. Use 'ssh -i c4-test1/eks-a-id_rsa <username>@<Node-IP-Address>' to login to your cluster node
✅ Vsphere Provider setup is valid
✅ Validate certificate for registry mirror
✅ Validate authentication for git provider
✅ Create preflight validations pass
Creating new bootstrap cluster
Provider specific pre-capi-install-setup on bootstrap cluster
Installing cluster-api providers on bootstrap cluster
Provider specific post-setup
Creating new workload cluster
Installing networking on workload cluster
Installing storage class on cluster
Creating EKS-A namespace
Installing cluster-api providers on workload cluster
Installing EKS-A secrets on workload cluster
Installing resources on management cluster
Moving cluster management from bootstrap to workload cluster
Installing EKS-A custom components (CRD and controller) on workload cluster
Installing EKS-D components on workload cluster
Creating EKS-A CRDs instances on workload cluster
Installing GitOps Toolkit on workload cluster
GitOps field not specified, bootstrap flux skipped
Writing cluster config file
Deleting bootstrap cluster
--------------------------------------------------------------------------------------
🎉 Cluster created!
The Amazon EKS Anywhere Curated Packages are only available to customers with the
Amazon EKS Anywhere Enterprise Subscription
--------------------------------------------------------------------------------------
```
* Once the cluster is created, switch the kubectl context using the handy script.
```
source $HOME/eks-anywhere/cluster-ops/switch-cluster.sh
```
* Observe the nodes created 
```
kubectl get nodes
NAME                             STATUS   ROLES                  AGE   VERSION
c4-test1-5h2cc                   Ready    control-plane,master   16m   v1.23.13-eks-6022eca
c4-test1-5jq7x                   Ready    control-plane,master   18m   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-dz7rm   Ready    <none>                 17m   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-vxpr2   Ready    <none>                 17m   v1.23.13-eks-6022eca
c4-test1-md-1-5bb6cc665d-pm656   Ready    <none>                 17m   v1.23.13-eks-6022eca
c4-test1-md-1-5bb6cc665d-zt2k2   Ready    <none>                 17m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-nfng9    Ready    <none>                 17m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-nhq2q    Ready    <none>                 17m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-r47lt    Ready    <none>                 17m   v1.23.13-eks-6022eca
```
Observe the node group lables applied to each of the worker pool nodes (md-0, md-1, md-2)
```
kubectl get no -o json | jq -r '[.items[] | {name:.metadata.name, nodegroup:.metadata.labels.group}]'
[
  {
    "name": "c4-test1-5h2cc",
    "nodegroup": null
  },
  {
    "name": "c4-test1-5jq7x",
    "nodegroup": null
  },
  {
    "name": "c4-test1-md-0-7c96df97f5-dz7rm",
    "nodegroup": "md-0"
  },
  {
    "name": "c4-test1-md-0-7c96df97f5-vxpr2",
    "nodegroup": "md-0"
  },
  {
    "name": "c4-test1-md-1-5bb6cc665d-pm656",
    "nodegroup": "md-1"
  },
  {
    "name": "c4-test1-md-1-5bb6cc665d-zt2k2",
    "nodegroup": "md-1"
  },
  {
    "name": "c4-test1-md-2-dc96644c7-nfng9",
    "nodegroup": "md-2"
  },
  {
    "name": "c4-test1-md-2-dc96644c7-nhq2q",
    "nodegroup": "md-2"
  },
  {
    "name": "c4-test1-md-2-dc96644c7-r47lt",
    "nodegroup": "md-2"
  }
]
```
* Deploy the metrics server.
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - nodes/metrics
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls
        image: registry.k8s.io/metrics-server/metrics-server:v0.6.3
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
EOF
```
* Deploy the Cluster Autoscaler. PLEASE CHANGE THE CLUSTER NAME in the below configuration where the container args are mentioned. The below configuration bears the cluster name as c4-test1. Change the same to the name of the workload cluster.
```
cat <<EOF | kubectl apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-1-autoscaler-management
  namespace: kube-system
  labels:
    app: cluster-autoscaler
spec:
  selector:
    matchLabels:
      app: cluster-autoscaler
  replicas: 1
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.20.0 # that matches the K8s version. https://github.com/kubernetes/autoscaler/releases
        name: cluster-autoscaler
        command:
        - /cluster-autoscaler
        args:
        - --cloud-provider=clusterapi
        - --node-group-auto-discovery=clusterapi:clusterName=c4-test1
      serviceAccountName: cluster-autoscaler
      terminationGracePeriodSeconds: 10
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-autoscaler-workload
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-autoscaler-workload
subjects:
- kind: ServiceAccount
  name: cluster-autoscaler
  namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-autoscaler-management
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-autoscaler-management
subjects:
- kind: ServiceAccount
  name: cluster-autoscaler
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cluster-autoscaler
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-autoscaler-workload
rules:
  - apiGroups:
    - ""
    resources:
    - namespaces
    - persistentvolumeclaims
    - persistentvolumes
    - pods
    - replicationcontrollers
    - services
    verbs:
    - get
    - list
    - watch
  - apiGroups:
    - ""
    resources:
    - nodes
    verbs:
    - get
    - list
    - update
    - watch
  - apiGroups:
    - ""
    resources:
    - pods/eviction
    verbs:
    - create
  - apiGroups:
    - policy
    resources:
    - poddisruptionbudgets
    verbs:
    - list
    - watch
  - apiGroups:
    - storage.k8s.io
    resources:
    - csinodes
    - storageclasses
    - csidrivers
    - csistoragecapacities
    verbs:
    - get
    - list
    - watch
  - apiGroups:
    - batch
    resources:
    - jobs
    verbs:
    - list
    - watch
  - apiGroups:
    - apps
    resources:
    - daemonsets
    - replicasets
    - statefulsets
    verbs:
    - list
    - watch
  - apiGroups:
    - ""
    resources:
    - events
    verbs:
    - create
    - patch
  - apiGroups:
    - ""
    resources:
    - configmaps
    verbs:
    - create
    - delete
    - get
    - update
  - apiGroups:
    - coordination.k8s.io
    resources:
    - leases
    verbs:
    - create
    - get
    - update
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-autoscaler-management
rules:
  - apiGroups:
    - cluster.x-k8s.io
    resources:
    - machinedeployments
    - machinedeployments/scale
    - machines
    - machinesets
    verbs:
    - get
    - list
    - update
    - watch
EOF
```
* Deploy a sample manifest for Busybox with a nodeSelector value of group equals md-0 and observe whether the pods are correctly placed on md-0 nodes by describing them.
```
cat <<EOF | kubectl apply -f -
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: busybox
      namespace: default
    spec:
      progressDeadlineSeconds: 600
      replicas: 2
      selector:
        matchLabels:
          run: busybox
      template:
        metadata:
          labels:
            run: busybox
        spec:
          nodeSelector:
            group: md-0
          containers:
          - args:
            - sh
            image: busybox
            imagePullPolicy: "IfNotPresent"
            name: busybox
            stdin: true
            tty: true
            resources:
              limits:
                cpu: 500m
              requests:
                cpu: 500m          
EOF
```
Observe that the busybox pods have come up on the node bearing the group label of md-0
```
kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
busybox-8484f45b44-lnzvp   1/1     Running   0          12m
busybox-8484f45b44-nm9lz   1/1     Running   0          12m

kubectl get pods -o json | jq -r '[.items[] | {podname:.metadata.name, nodename:.spec.nodeName}]'
[
  {
    "podname": "busybox-8484f45b44-lnzvp",
    "nodename": "c4-test1-md-0-7c96df97f5-vxpr2"
  },
  {
    "podname": "busybox-8484f45b44-nm9lz",
    "nodename": "c4-test1-md-0-7c96df97f5-dz7rm"
  }
]
```
* Edit the deployment for Busybox using kubectl and change the nodeSelector group value to md-1 
```
KUBE_EDITOR="nano" kubectl edit deployment busybox
deployment.apps/busybox edited

kubectl get pods
NAME                       READY   STATUS              RESTARTS   AGE
busybox-75cf886847-f97jp   0/1     ContainerCreating   0          2s
busybox-75cf886847-p8nnm   1/1     Running             0          11s
busybox-8484f45b44-lnzvp   1/1     Running             0          21m
busybox-8484f45b44-nm9lz   1/1     Terminating         0          21m

kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
busybox-75cf886847-f97jp   1/1     Running   0          42s
busybox-75cf886847-p8nnm   1/1     Running   0          51s

kubectl get pods -o json | jq -r '[.items[] | {podname:.metadata.name, nodename:.spec.nodeName}]'
[
  {
    "podname": "busybox-75cf886847-f97jp",
    "nodename": "c4-test1-md-1-5bb6cc665d-pm656"
  },
  {
    "podname": "busybox-75cf886847-p8nnm",
    "nodename": "c4-test1-md-1-5bb6cc665d-zt2k2"
  }
]
```
* Edit the deployment for Busybox using kubectl and change the nodeSelector group value to md-2
```
KUBE_EDITOR="nano" kubectl edit deployment busybox
deployment.apps/busybox edited

kubectl get pods
NAME                       READY   STATUS              RESTARTS   AGE
busybox-65dc8f7ff8-l7jd8   0/1     ContainerCreating   0          6s
busybox-65dc8f7ff8-wpvnm   1/1     Running             0          15s
busybox-75cf886847-f97jp   1/1     Terminating         0          2m18s
busybox-75cf886847-p8nnm   1/1     Running             0          2m27s

kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
busybox-65dc8f7ff8-l7jd8   1/1     Running   0          41s
busybox-65dc8f7ff8-wpvnm   1/1     Running   0          50s

 kubectl get pods -o json | jq -r '[.items[] | {podname:.metadata.name, nodename:.spec.nodeName}]'
[
  {
    "podname": "busybox-65dc8f7ff8-l7jd8",
    "nodename": "c4-test1-md-2-dc96644c7-nhq2q"
  },
  {
    "podname": "busybox-65dc8f7ff8-wpvnm",
    "nodename": "c4-test1-md-2-dc96644c7-r47lt"
  }
]
```
## CLUSTER AUTOSCALING
* Next, we will test cluster auto-scaling by increasing the replica count of busybox deployment to 50. This will push the expectations from the underlying cluster and a lot of busybox pods will go into pending state. 
* This is where Cluster Autoscaler will start expanding the virtual machine pools associated with a particular node group
* As a pre-requisite, ensure cluster autoscaler is successfully running 
```
kubectl get pods -n kube-system | grep cluster
cluster-1-autoscaler-management-7c96fdbc56-lthp5   1/1     Running   0             3m59s
```
* Edit the busybox deployment  and while doing so
- alter the replica count from 2 to a new value of 50
- Change the nodeSelector value for busybox back to md-0
```
KUBE_EDITOR="nano" kubectl edit deployment busybox
deployment.apps/busybox edited

kubectl get pods
NAME                       READY   STATUS              RESTARTS   AGE
busybox-65dc8f7ff8-2sm78   1/1     Terminating         0          28s
busybox-65dc8f7ff8-2zwr5   1/1     Terminating         0          28s
busybox-65dc8f7ff8-4dhkc   0/1     ContainerCreating   0          27s
busybox-65dc8f7ff8-4kxhb   1/1     Running             0          28s
busybox-65dc8f7ff8-4xlw4   1/1     Running             0          28s
busybox-65dc8f7ff8-579dz   1/1     Terminating         0          27s
busybox-65dc8f7ff8-5b7br   1/1     Running             0          28s
busybox-65dc8f7ff8-6gbs7   1/1     Terminating         0          27s
busybox-65dc8f7ff8-7jkkp   1/1     Running             0          28s
busybox-65dc8f7ff8-9bpms   1/1     Running             0          28s
busybox-65dc8f7ff8-bf4j6   1/1     Running             0          28s
busybox-65dc8f7ff8-bmr7h   1/1     Running             0          28s
busybox-65dc8f7ff8-dbvcj   1/1     Terminating         0          28s
busybox-65dc8f7ff8-f6b9k   1/1     Running             0          28s
busybox-65dc8f7ff8-fw77c   1/1     Running             0          28s
busybox-65dc8f7ff8-gfjtz   1/1     Terminating         0          28s
busybox-65dc8f7ff8-gvnkt   0/1     ContainerCreating   0          28s
busybox-65dc8f7ff8-hfk8h   1/1     Running             0          28s
busybox-65dc8f7ff8-hhhj4   0/1     ContainerCreating   0          28s
busybox-65dc8f7ff8-kj57g   0/1     ContainerCreating   0          28s
busybox-65dc8f7ff8-kk45l   1/1     Running             0          28s
busybox-65dc8f7ff8-klkcw   1/1     Running             0          28s
busybox-65dc8f7ff8-l7jd8   1/1     Running             0          11m
busybox-65dc8f7ff8-mb8hx   0/1     ContainerCreating   0          28s
busybox-65dc8f7ff8-mgvkh   0/1     ContainerCreating   0          27s
busybox-65dc8f7ff8-mj49p   1/1     Terminating         0          27s
busybox-65dc8f7ff8-pfw9q   1/1     Running             0          28s
busybox-65dc8f7ff8-px6wm   1/1     Running             0          28s
busybox-65dc8f7ff8-qdkjw   1/1     Terminating         0          27s
busybox-65dc8f7ff8-shl9d   1/1     Terminating         0          28s
busybox-65dc8f7ff8-vdsrz   1/1     Terminating         0          27s
busybox-65dc8f7ff8-vj6nr   0/1     ContainerCreating   0          27s
busybox-65dc8f7ff8-wpvnm   1/1     Running             0          11m
busybox-65dc8f7ff8-z5mmt   0/1     ContainerCreating   0          28s
busybox-8484f45b44-2pr9r   0/1     Pending             0          21s
busybox-8484f45b44-5rbs2   0/1     Pending             0          16s
busybox-8484f45b44-6ld5r   1/1     Running             0          28s
busybox-8484f45b44-84gvm   0/1     Pending             0          20s
busybox-8484f45b44-bgmn5   1/1     Running             0          28s
busybox-8484f45b44-bqkwn   0/1     Pending             0          26s
busybox-8484f45b44-c7fdr   1/1     Running             0          28s
busybox-8484f45b44-clcvl   1/1     Running             0          28s
busybox-8484f45b44-czmj9   0/1     Pending             0          22s
busybox-8484f45b44-dsbxq   0/1     Pending             0          25s
busybox-8484f45b44-dsjc2   0/1     Pending             0          19s
busybox-8484f45b44-fqz42   0/1     Pending             0          26s
busybox-8484f45b44-h5grq   0/1     Pending             0          21s
busybox-8484f45b44-jxgst   0/1     Pending             0          14s
busybox-8484f45b44-k7jm5   1/1     Running             0          28s
busybox-8484f45b44-ldskl   0/1     Pending             0          21s
busybox-8484f45b44-lhlrs   0/1     Pending             0          19s
busybox-8484f45b44-lj54v   1/1     Running             0          28s
busybox-8484f45b44-lxt4n   0/1     Pending             0          25s
busybox-8484f45b44-nw6jl   0/1     Pending             0          25s
busybox-8484f45b44-ps5bb   1/1     Running             0          28s
busybox-8484f45b44-ptbvh   1/1     Running             0          28s
busybox-8484f45b44-q2kfg   0/1     Pending             0          25s
busybox-8484f45b44-qbcsp   0/1     Pending             0          22s
busybox-8484f45b44-qssdg   0/1     Pending             0          19s
busybox-8484f45b44-r7dhr   0/1     Pending             0          21s
busybox-8484f45b44-rgbvl   0/1     Pending             0          16s
busybox-8484f45b44-rkvdb   0/1     Pending             0          25s
busybox-8484f45b44-rlcf5   1/1     Running             0          28s
busybox-8484f45b44-rszlc   1/1     Running             0          28s
busybox-8484f45b44-s7svl   0/1     Pending             0          26s
busybox-8484f45b44-skv47   0/1     Pending             0          26s
busybox-8484f45b44-vmtdw   0/1     Pending             0          26s
busybox-8484f45b44-wdjbt   0/1     Pending             0          22s
busybox-8484f45b44-x94l7   1/1     Running             0          26s
busybox-8484f45b44-x9dzs   1/1     Running             0          28s
busybox-8484f45b44-zcbr2   1/1     Running             0          28s
busybox-8484f45b44-zfndd   0/1     Pending             0          25s
busybox-8484f45b44-zqzn6   1/1     Running             0          28s
```
* Observe that the cluster autoscaler has already detected pending pods and has triggered addition of nodes in the worker pool labeled with md-0
```
 kubectl get nodes
NAME                             STATUS     ROLES                  AGE   VERSION
c4-test1-5h2cc                   Ready      control-plane,master   54m   v1.23.13-eks-6022eca
c4-test1-5jq7x                   Ready      control-plane,master   56m   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-5jdjn   NotReady   <none>                 11s   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-5x7mh   NotReady   <none>                 3s    v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-dz7rm   Ready      <none>                 55m   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-jmnqp   NotReady   <none>                 10s   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-vxpr2   Ready      <none>                 55m   v1.23.13-eks-6022eca
c4-test1-md-1-5bb6cc665d-pm656   Ready      <none>                 55m   v1.23.13-eks-6022eca
c4-test1-md-1-5bb6cc665d-zt2k2   Ready      <none>                 55m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-nfng9    Ready      <none>                 55m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-nhq2q    Ready      <none>                 55m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-r47lt    Ready      <none>                 55m   v1.23.13-eks-6022eca

kubectl get nodes
NAME                             STATUS   ROLES                  AGE   VERSION
c4-test1-5h2cc                   Ready    control-plane,master   55m   v1.23.13-eks-6022eca
c4-test1-5jq7x                   Ready    control-plane,master   57m   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-5jdjn   Ready    <none>                 99s   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-5x7mh   Ready    <none>                 91s   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-dz7rm   Ready    <none>                 56m   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-jmnqp   Ready    <none>                 98s   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-vxpr2   Ready    <none>                 56m   v1.23.13-eks-6022eca
c4-test1-md-1-5bb6cc665d-pm656   Ready    <none>                 56m   v1.23.13-eks-6022eca
c4-test1-md-1-5bb6cc665d-zt2k2   Ready    <none>                 56m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-nfng9    Ready    <none>                 56m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-nhq2q    Ready    <none>                 56m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-r47lt    Ready    <none>                 56m   v1.23.13-eks-6022eca
```
* A few pods may still be in pending state as the md-0 worker node group is capped at a maxCount of 5
```
kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
busybox-65dc8f7ff8-hfk8h   1/1     Running   0          3m39s
busybox-65dc8f7ff8-l7jd8   1/1     Running   0          14m
busybox-65dc8f7ff8-wpvnm   1/1     Running   0          14m
busybox-8484f45b44-2pr9r   1/1     Running   0          3m32s
busybox-8484f45b44-5rbs2   0/1     Pending   0          3m27s
busybox-8484f45b44-5wq6j   0/1     Pending   0          75s
busybox-8484f45b44-65r4x   0/1     Pending   0          85s
busybox-8484f45b44-6ld5r   1/1     Running   0          3m39s
busybox-8484f45b44-6xwjq   0/1     Pending   0          79s
busybox-8484f45b44-7q2bd   0/1     Pending   0          81s
busybox-8484f45b44-84gvm   1/1     Running   0          3m31s
busybox-8484f45b44-b8796   0/1     Pending   0          83s
busybox-8484f45b44-bgmn5   1/1     Running   0          3m39s
busybox-8484f45b44-bqkwn   1/1     Running   0          3m37s
busybox-8484f45b44-c7fdr   1/1     Running   0          3m39s
busybox-8484f45b44-clcvl   1/1     Running   0          3m39s
busybox-8484f45b44-czmj9   1/1     Running   0          3m33s
busybox-8484f45b44-dsbxq   1/1     Running   0          3m36s
busybox-8484f45b44-dsjc2   1/1     Running   0          3m30s
busybox-8484f45b44-fqz42   1/1     Running   0          3m37s
busybox-8484f45b44-h5grq   1/1     Running   0          3m32s
busybox-8484f45b44-jnsgv   0/1     Pending   0          83s
busybox-8484f45b44-jxgst   0/1     Pending   0          3m25s
busybox-8484f45b44-k7jm5   1/1     Running   0          3m39s
busybox-8484f45b44-kvtl7   0/1     Pending   0          97s
busybox-8484f45b44-ldskl   1/1     Running   0          3m32s
busybox-8484f45b44-lhlrs   1/1     Running   0          3m30s
busybox-8484f45b44-lj54v   1/1     Running   0          3m39s
busybox-8484f45b44-lxt4n   1/1     Running   0          3m36s
busybox-8484f45b44-lz86c   0/1     Pending   0          94s
busybox-8484f45b44-nw6jl   1/1     Running   0          3m36s
busybox-8484f45b44-nwb2h   0/1     Pending   0          79s
busybox-8484f45b44-ps5bb   1/1     Running   0          3m39s
busybox-8484f45b44-ptbvh   1/1     Running   0          3m39s
busybox-8484f45b44-q2kfg   1/1     Running   0          3m36s
busybox-8484f45b44-qbcsp   1/1     Running   0          3m33s
busybox-8484f45b44-qssdg   0/1     Pending   0          3m30s
busybox-8484f45b44-r7dhr   1/1     Running   0          3m32s
busybox-8484f45b44-rgbvl   0/1     Pending   0          3m27s
busybox-8484f45b44-rkvdb   1/1     Running   0          3m36s
busybox-8484f45b44-rlcf5   1/1     Running   0          3m39s
busybox-8484f45b44-rszlc   1/1     Running   0          3m39s
busybox-8484f45b44-s7svl   1/1     Running   0          3m37s
busybox-8484f45b44-skv47   1/1     Running   0          3m37s
busybox-8484f45b44-vmtdw   1/1     Running   0          3m37s
busybox-8484f45b44-vqx92   0/1     Pending   0          96s
busybox-8484f45b44-wdjbt   1/1     Running   0          3m33s
busybox-8484f45b44-x94l7   1/1     Running   0          3m37s
busybox-8484f45b44-x9dzs   1/1     Running   0          3m39s
busybox-8484f45b44-z8bc6   0/1     Pending   0          82s
busybox-8484f45b44-zcbr2   1/1     Running   0          3m39s
busybox-8484f45b44-zfndd   1/1     Running   0          3m36s
busybox-8484f45b44-zqzn6   1/1     Running   0          3m39s
```
* Time to scale-in and get things back to original state
* Scale down the replica count for busybox from 50 to 2. This will start terminating the busybox pods to scale in the overall deployment to 2 replicas. However, cluster autoscaler will not start changing things immediately due to various default timers. Wait for approximately 10–15 minutes and one can observe the node count for the worker pool labeled as md-0 scale in from the maxCount of 5 to the minCount of 2
```
 KUBE_EDITOR="nano" kubectl edit deployment busybox
deployment.apps/busybox edited

kubectl get pods
NAME                       READY   STATUS        RESTARTS   AGE
busybox-65dc8f7ff8-hfk8h   1/1     Terminating   0          5m32s
busybox-65dc8f7ff8-l7jd8   1/1     Terminating   0          16m
busybox-65dc8f7ff8-wpvnm   1/1     Terminating   0          16m
busybox-8484f45b44-2pr9r   1/1     Terminating   0          5m25s
busybox-8484f45b44-6ld5r   1/1     Running       0          5m32s
busybox-8484f45b44-84gvm   1/1     Terminating   0          5m24s
busybox-8484f45b44-bgmn5   1/1     Terminating   0          5m32s
busybox-8484f45b44-bqkwn   1/1     Terminating   0          5m30s
busybox-8484f45b44-c7fdr   1/1     Terminating   0          5m32s
busybox-8484f45b44-clcvl   1/1     Terminating   0          5m32s
busybox-8484f45b44-czmj9   1/1     Terminating   0          5m26s
busybox-8484f45b44-dsbxq   1/1     Terminating   0          5m29s
busybox-8484f45b44-dsjc2   1/1     Terminating   0          5m23s
busybox-8484f45b44-fqz42   1/1     Terminating   0          5m30s
busybox-8484f45b44-h5grq   1/1     Terminating   0          5m25s
busybox-8484f45b44-k7jm5   1/1     Terminating   0          5m32s
busybox-8484f45b44-ldskl   1/1     Terminating   0          5m25s
busybox-8484f45b44-lhlrs   1/1     Terminating   0          5m23s
busybox-8484f45b44-lj54v   1/1     Terminating   0          5m32s
busybox-8484f45b44-lxt4n   1/1     Terminating   0          5m29s
busybox-8484f45b44-nw6jl   1/1     Terminating   0          5m29s
busybox-8484f45b44-ps5bb   1/1     Terminating   0          5m32s
busybox-8484f45b44-ptbvh   1/1     Terminating   0          5m32s
busybox-8484f45b44-q2kfg   1/1     Terminating   0          5m29s
busybox-8484f45b44-qbcsp   1/1     Terminating   0          5m26s
busybox-8484f45b44-r7dhr   1/1     Terminating   0          5m25s
busybox-8484f45b44-rkvdb   1/1     Terminating   0          5m29s
busybox-8484f45b44-rlcf5   1/1     Terminating   0          5m32s
busybox-8484f45b44-rszlc   1/1     Terminating   0          5m32s
busybox-8484f45b44-s7svl   1/1     Terminating   0          5m30s
busybox-8484f45b44-skv47   1/1     Terminating   0          5m30s
busybox-8484f45b44-vmtdw   1/1     Terminating   0          5m30s
busybox-8484f45b44-wdjbt   1/1     Terminating   0          5m26s
busybox-8484f45b44-x94l7   1/1     Terminating   0          5m30s
busybox-8484f45b44-x9dzs   1/1     Terminating   0          5m32s
busybox-8484f45b44-zcbr2   1/1     Running       0          5m32s
busybox-8484f45b44-zfndd   1/1     Terminating   0          5m29s
busybox-8484f45b44-zqzn6   1/1     Terminating   0          5m32s
```
* Cluster autoscaler will not immediately start triggering changes due to default cool down timers
* The md-0 node count is maintained during this cool down timer
```
kubectl get nodes
NAME                             STATUS   ROLES                  AGE     VERSION
c4-test1-5h2cc                   Ready    control-plane,master   59m     v1.23.13-eks-6022eca
c4-test1-5jq7x                   Ready    control-plane,master   61m     v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-5jdjn   Ready    <none>                 5m29s   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-5x7mh   Ready    <none>                 5m21s   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-dz7rm   Ready    <none>                 60m     v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-jmnqp   Ready    <none>                 5m28s   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-vxpr2   Ready    <none>                 60m     v1.23.13-eks-6022eca
c4-test1-md-1-5bb6cc665d-pm656   Ready    <none>                 60m     v1.23.13-eks-6022eca
c4-test1-md-1-5bb6cc665d-zt2k2   Ready    <none>                 60m     v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-nfng9    Ready    <none>                 60m     v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-nhq2q    Ready    <none>                 60m     v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-r47lt    Ready    <none>                 60m     v1.23.13-eks-6022eca
```
* Wait for approximately 10-11 minutes
```
 kubectl get nodes
NAME                             STATUS   ROLES                  AGE   VERSION
c4-test1-5h2cc                   Ready    control-plane,master   70m   v1.23.13-eks-6022eca
c4-test1-5jq7x                   Ready    control-plane,master   71m   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-dz7rm   Ready    <none>                 70m   v1.23.13-eks-6022eca
c4-test1-md-0-7c96df97f5-vxpr2   Ready    <none>                 70m   v1.23.13-eks-6022eca
c4-test1-md-1-5bb6cc665d-pm656   Ready    <none>                 70m   v1.23.13-eks-6022eca
c4-test1-md-1-5bb6cc665d-zt2k2   Ready    <none>                 70m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-nfng9    Ready    <none>                 70m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-nhq2q    Ready    <none>                 70m   v1.23.13-eks-6022eca
c4-test1-md-2-dc96644c7-r47lt    Ready    <none>                 70m   v1.23.13-eks-6022eca
```
