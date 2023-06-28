Validated to work with EKS-A
```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.config.allow-snippet-annotations="true" \
  --set controller.config.proxy-buffer-size="32k" \
  --set controller.config.proxy-buffers="4 32k" \
  --set controller.config.proxy-read-timeout="600" \
  --set "controller.extraArgs.enable-ssl-passthrough=" \
  --set "controller.extraArgs.validating-webhook=:8443" \
  --set "controller.extraArgs.validating-webhook-certificate=/usr/local/certificates/cert" \
  --set "controller.extraArgs.validating-webhook-key=/usr/local/certificates/key" \
  --set controller.service.loadBalancerIP="172.24.165.17"
```
