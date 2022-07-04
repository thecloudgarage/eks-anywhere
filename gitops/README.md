* Setup the Gitlab instance either with OIDC or non-OIDC
* Login to Gitlab and verify user login with user-admin 

```
# On the EKS Admin machine., create the SSH keys for Gitlab that Flux will use
ssh-keygen -t ecdsa -C "user_admin@thecloudgarage.com"
# Provide The name of the key as a path on the EKS Admin machine, e.g. flux-gitlab
# This key name will be used to perform SSH by Flux to read/write into GitLab
# Change permissions
chmod 600 $HOME/.ssh/gitlab
```

* Copy the public key to Gitlab (preferences > SSH Keys)
* Next scan the public key from Gitlab to ensure authenticity and add it to a file called my_eksa_known_hosts
* This will ensure that authenticity is not questioned via the known hosts file

```
ssh-keyscan -t -p 2224 ecdsa gitlab.oidc.thecloudgarage.com >> my_eksa_known_hosts

* 
create a test repository and initialize it with a README.md
