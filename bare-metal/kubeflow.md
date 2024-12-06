```
brew install kustomize
kubectl patch storageclass powerscale -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
git clone https://github.com/kubeflow/manifests.git
cd manifests
while ! kustomize build  example | kubectl apply -f - --server-side --force-conflicts; do echo "Retrying to apply resources"; sleep 10; done
```
Preferably on windows, download and run kubectl
```
https://site-ghwmnxe1v6.talkyard.net/-12/faq-how-to-set-up-kubeconfig-on-windows-wise-paasensaas-k8s-service
```
Launch a notebook with tensorflow image
```
import tensorflow as tf
print("Num GPUs Available: ", len(tf.config.experimental.list_physical_devices('GPU')))
```
