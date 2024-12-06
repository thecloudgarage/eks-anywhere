Install MetalLB
```
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb --wait --timeout 15m --namespace metallb-system --create-namespace
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.29.198.75-172.29.198.76
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF
```
Install Ollama
```
cat <<EOF > $HOME/ollama/ollama-values.yaml

ollama:
  gpu:
    # -- Enable GPU integration
    enabled: true

    # -- GPU type: 'nvidia' or 'amd'
    type: 'nvidia'

    # -- Specify the number of GPU to 1
    number: 2
EOF

helm repo add ollama-helm https://otwld.github.io/ollama-helm/
helm repo update
helm upgrade -i ollama ollama-helm/ollama --create-namespace --namespace ollama -f $HOME/ollama/ollama-values.yaml
```
Install Open-WebUI
```
kubectl create namespace open-webui
kubectl apply -f https://raw.githubusercontent.com/open-webui/open-webui/main/kubernetes/manifest/base/webui-service.yaml
kubectl apply -f https://raw.githubusercontent.com/open-webui/open-webui/main/kubernetes/manifest/base/webui-deployment.yaml
```
- Edit the open-webui deployment and comment the persistent volume dependency if you don't have a CSI integrated
- Additionally change the base URL for Ollama to ollama.ollama.svc.cluster.local:11434
```
KUBE_EDITOR="nano" kubectl edit deployment open-webui-deployment -n open-webui
```
- Edit the opeb-webui service and change it to LoadBalancer
- For persistent volume claims, ensure a default storage class exists
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: open-webui-pvc
  namespace: open-webui
  labels:
    name: open-webui-pvc
    csi: powerscale
spec:
  storageClassName: powerscale
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 4Gi
EOF
```


