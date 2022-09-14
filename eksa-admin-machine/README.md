# Important note: Breaking changes in EKS Anywhere v0.11 package

* Starting v0.11 EKS Anywhere does not allow automatic downloads of the UBUNTU OS for EKS Anywhere nodes
* This was not the case with EKS Anywhere package v0.10
* As of now there are no documented steps to manually install v0.10 package
* As a result, brew install aws/tap/eks-anywhere will lead to a default latest release of v0.11 installation
* So customers who were running previous versions of EKS Anywhere are stuck in a limbo if they planned their deployments on ubuntu
* Alternatively, AWS has recommended a procedure of manually downloading the OVA and importing those via a slightly more involved process

# What's the workaround
* Being a set of open-source projects, fortunately, there is a simpler way that I have leveraged
* I have cloned v0.10.1 release of EKS Anywhere Brew Tap into my GitHub account
* So if one wants to stay with v0.10.1 and the default method of automatically downloading ubuntu into the content repositories, etc., then the below command will satisfy all the requirements and do the needful

```
brew install thecloudgarage/aws-homebrew-tap/eks-anywhere
```
