### This version of sock-shop application is built to be used on EKS Anywhere clusters along with Dell's PowerStore CSI
* MetalLB and PowerStore CSI should be deployed as a prior pre-requisite on the EKS Anywhere cluster
* A deployment script and delete script is provided that will renderdestroy all the required resources
* The application frontend is built to suit a FQDN with SSL style of deployment., so you will need access to creating DNS records
* Once the deployment is complete., create a DNS entry with the host value and the Ingress IP address
* Validate the application workflow
