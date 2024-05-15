* Setup the Gitlab instance either with OIDC or non-OIDC
* Login to Gitlab GUI and verify user login with user-admin
* Note the docker-compose files for Gitlab will expose the GUI at port 10443 and SSH at 2224
* On the EKS Admin machine., create the SSH keys for Gitlab that Flux will use
* In my example, I am storing the generated keys as $HOME/.ssh/gitlab
```
# EXPORT THE REQUIRED VARIABLES IN PROFILE
cd $HOME
echo "EKSA_GIT_PRIVATE_KEY=/home/ubuntu/.ssh/gitlab; export EKSA_GIT_PRIVATE_KEY" >> ~/.profile
echo "SSH_KNOWN_HOSTS=/home/ubuntu/.ssh/known_hosts; export SSH_KNOWN_HOSTS" >> ~/.profile
echo "EKSA_GIT_KNOWN_HOSTS=/home/ubuntu/.ssh/known_hosts; export EKSA_GIT_KNOWN_HOSTS" >> ~/.profile
source .profile
```
Generate SSH keys for Gitlab
```
ssh-keygen -t ecdsa -C "user_admin@your-domain-name" (for azure AD, use the principal name,e.g. ambar@ambaru2ubegmail.onmicrosoft.com)
eval "$(ssh-agent -s)" && ssh-add $EKSA_GIT_PRIVATE_KEY
cat $EKSA_GIT_PRIVATE_KEY.pub
chmod 600 $EKSA_GIT_PRIVATE_KEY
```
* Copy the public key to Gitlab via GUI (User icon > preferences > SSH Keys)
* Now that the public key is in Gitlab, we need to SSH so that it is stored in the ./ssh/known_hosts file
```
ssh -i gitlab git@gitlab1.poc.thecloudgarage.com -p 2224
``` 
* EKSA will use two variables and automatically inject them for FLUX operations (secret creation, connecting to gitlab, etc.)
* Let's export these three variables within the cluster creation script.. Insert the below in the cluster creation script.
* Do not export them outside the script as they bash would not be able to access them
* Also ensure the FluxConfig configuration uses the correct SSH port number in the repositoryUrl for SSH (In my case it's 2224)
* In addition, create an empty repository before-hand with the name specified in the FluxConfig in Cluster's YAML
* Example:
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
