#!/bin/bash
read -sp 'vSphereUserName: ' vSphereUserName
echo -e "\n"
read -sp 'vSpherePassword: ' vSpherePassword
echo -e "\n"
sed -i '/^EKSA_VSPHERE_/d' /home/ubuntu/.profile
#echo "EKSA_VSPHERE_USERNAME=$vSphereUserName; export EKSA_VSPHERE_USERNAME" >> ~/.profile
#echo "EKSA_VSPHERE_PASSWORD=$vSpherePassword; export EKSA_VSPHERE_PASSWORD" >> ~/.profile
#EKS ANYWHERE DOCUMENTATION suggests using single quotes in exported variables for vsphere logins
#The below escaped single quotes will be presented along with username and password in the env output
echo "EKSA_VSPHERE_USERNAME=\'$vSphereUserName\'; export EKSA_VSPHERE_USERNAME" >> ~/.profile
echo "EKSA_VSPHERE_PASSWORD=\'$vSpherePassword\'; export EKSA_VSPHERE_PASSWORD" >> ~/.profile
