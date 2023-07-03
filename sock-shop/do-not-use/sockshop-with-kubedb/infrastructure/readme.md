Perform this to ensure files are referencing the correct cluster name
```
grep -rl EKSA_CLUSTER_NAME . | xargs sed -i "s/EKSA_CLUSTER_NAME/$CLUSTER_NAME/g"
```
