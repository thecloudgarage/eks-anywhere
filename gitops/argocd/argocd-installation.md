### All the options are with LoadBalancer. Please install MetalLB beforhand

### Option-1 YAML install without OIDC
```
kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.4/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n argocd
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Option-2 HELM based installation with OIDC
```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd --namespace argocd --create-namespace --values - <<EOF
redis:
  enabled: true
redis-ha:
  enabled: false
server:
  service:
    type: LoadBalancer
  config:
    url: https://argocd.oidc.thecloudgarage.com
    application.instanceLabelKey: argocd.argoproj.io/instance
    admin.enabled: 'false'
    resource.exclusions: |
      - apiGroups:
          - cilium.io
        kinds:
          - CiliumIdentity
        clusters:
          - '*'
    oidc.config: |
      name: Keycloak
      issuer: http://keycloak.thecloudgarage.com/auth/realms/master
      clientID: kube
      cliClientID: argocdcligrpc
      clientSecret: kube-client-secret
      requestedScopes: ['openid', 'profile', 'email', 'groups']
    oidc.tls.insecure.skip.verify: "true"
  rbacConfig:
    policy.default: role:readonly
    policy.csv: |
      g, kube-admin, role:admin
EOF
```
### Option-3 HELM based installation with OIDC and Redis PVC
```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

CREATE PERSISTENT VOLUME CLAIM DEPENDING ON THE AVAILABLE STORAGE CLASS

kubectl create ns argocd
cat <<EOF | kubectl apply -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: argocd-redis
  namespace: argocd
  annotations:
    volume.beta.kubernetes.io/storage-class: "powerstore-ext4"
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
EOF

CONTINUE TO INSTALL ARGOCD

helm install argocd argo/argo-cd --namespace argocd --create-namespace --values - <<EOF
redis:
  enabled: true
  volumeMounts:
  - mountPath: /redis-master-data
    name: argocd-redis-persistent-storage
  volumes:
  - name: argocd-redis-persistent-storage
    persistentVolumeClaim:
      claimName: argocd-redis
redis-ha:
  enabled: false
server:
  service:
    type: LoadBalancer
  config:
    url: https://argocdtest.oidc.thecloudgarage.com
    application.instanceLabelKey: argocd.argoproj.io/instance
    admin.enabled: 'false'
    resource.exclusions: |
      - apiGroups:
          - cilium.io
        kinds:
          - CiliumIdentity
        clusters:
          - '*'
    oidc.config: |
      name: Keycloak
      issuer: http://keycloak.thecloudgarage.com/auth/realms/master
      clientID: kube
      cliClientID: argocdcligrpc
      clientSecret: kube-client-secret
      requestedScopes: ['openid', 'profile', 'email', 'groups']
    oidc.tls.insecure.skip.verify: "true"
  rbacConfig:
    policy.default: role:readonly
    policy.csv: |
      g, kube-admin, role:admin
EOF
