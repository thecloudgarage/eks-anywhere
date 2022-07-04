* Setup the Gitlab instance either with OIDC or non-OIDC
* Login to Gitlab GUI and verify user login with user-admin
* Note the docker-compose files for Gitlab will expose the GUI at port 10443 and SSH at 2224
* On the EKS Admin machine., create the SSH keys for Gitlab that Flux will use
* In my example, I am storing the generated keys as $HOME/.ssh/gitlab
```
ssh-keygen -t ecdsa -C "user_admin@your-domain-name"
```
* Provide The name of the key as a path on the EKS Admin machine, e.g. $HOME/.ssh/gitlab
* This key name will be used to perform SSH by Flux to read/write into GitLab
* Change permissions
```
chmod 600 $HOME/.ssh/gitlab
```
* Copy the public key to Gitlab via GUI (preferences > SSH Keys)
* Now that the public key is in Gitlab, we scan it and store it in our known hosts file
* In this case, and specifically for EKSA we will create a separate known hosts file for EKSA purposes
```
ssh-keyscan -t -p 2224 ecdsa your-gitlab-server-FQDN >> my_eksa_known_hosts
```
* EKSA will use two variables and automatically inject them for FLUX operations (secret creation, connecting to gitlab, etc.)
* Let's export these two variables on the EKS Admin machine (note I am using my example references, i.e. gitlab and my_eksa_known_hosts
```
export EKSA_GIT_PRIVATE_KEY=$HOME/.ssh/gitlab
export EKSA_GIT_KNOWN_HOSTS=$HOME/.ssh/my_eksa_known_hosts
```
* After this what follows is described in the blog post.
