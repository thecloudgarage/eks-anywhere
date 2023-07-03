Apply the changes before applying the files via Kustomize or GitOps
```
grep -rl EKSA_CLUSTER_NAME . | xargs sed -i "s/EKSA_CLUSTER_NAME/$CLUSTER_NAME/g"
```
