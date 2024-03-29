Install MetalLB (option-1 flat worker pool)
```
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb --wait --timeout 15m --namespace metallb-system --create-namespace
```
Install MetalLB (option-2 nodegroup support)
```
helm repo add metallb https://metallb.github.io/metallb
helm upgrade install metallb metallb/metallb --wait --timeout 15m \
--namespace metallb-system \
--create-namespace \
--set controller.nodeSelector."group"="md-2" \
--set speaker.nodeSelector."group"="md-2"
```
Configure MetalLB
```
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.24.165.21-172.24.165.25
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF
```
