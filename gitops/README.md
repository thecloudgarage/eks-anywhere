* Setup the Gitlab instance either with OIDC or non-OIDC
* Login to Gitlab GUI and verify user login with user-admin
* Note the docker-compose files for Gitlab will expose the GUI at port 10443 and SSH at 2224
* On the EKS Admin machine., create the SSH keys for Gitlab that Flux will use
* In my example, I am storing the generated keys as $HOME/.ssh/gitlab
```
ssh-keygen -t ecdsa -C "user_admin@your-domain-name" (for azure AD, use the principal name,e.g. ambar@ambaru2ubegmail.onmicrosoft.com)
```
* Provide The name of the key as a path on the EKS Admin machine, e.g. home/ubuntu/.ssh/gitlab
* This key name will be used to perform SSH by Flux to read/write into GitLab
* Change permissions
```
chmod 600 $HOME/.ssh/gitlab
```
* Copy the public key to Gitlab via GUI (User icon > preferences > SSH Keys)
* Now that the public key is in Gitlab, we scan it and store it in our known hosts file
```
ssh -i gitlab git@gitlab1.poc.thecloudgarage.com -p 2224
``` 
* EKSA will use two variables and automatically inject them for FLUX operations (secret creation, connecting to gitlab, etc.)
* Let's export these three variables within the cluster creation script.. Insert the below in the cluster creation script.
* Do not export them outside the script as they bash would not be able to access them
```
export EKSA_GIT_PRIVATE_KEY=$HOME/.ssh/gitlab
export EKSA_GIT_KNOWN_HOSTS=$HOME/.ssh/known_hosts
export SSH_KNOWN_HOSTS=$HOME/.ssh/known_hosts
echo $EKSA_GIT_PRIVATE_KEY
echo $EKSA_GIT_KNOWN_HOSTS
echo $SSH_KNOWN_HOSTS
```
Also ensure the OIDC configuration use 2224 port number in the git repository url for SSH
e.g. 
```
---
apiVersion: anywhere.eks.amazonaws.com/v1alpha1
kind: FluxConfig
metadata:
  name: my-flux-config
spec:
    git:
      repositoryUrl: ssh://git@gitlab1.poc.thecloudgarage.com:2224/ambar/flux-test.git
      sshKeyAlgorithm: ecdsa
```
# PROBLEM: The below specified method by AWS did not work
```
cd $HOME/.ssh/
ssh-keyscan -t ecdsa your-gitlab-server-FQDN >> my_eksa_known_hosts (without https or the port number)
```
