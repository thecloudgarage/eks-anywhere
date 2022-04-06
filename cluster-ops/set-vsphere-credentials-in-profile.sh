#!/bin/bash
read -sp 'vSphereUserName: ' vSphereUserName
read -sp 'vSpherePassword: ' vSpherePassword
sed -i '/^EKSA_VSPHERE_/d' /home/ubuntu/.profile
echo "EKSA_VSPHERE_USERNAME=$vSphereUserName; export EKSA_VSPHERE_USERNAME" >> ~/.profile
echo "EKSA_VSPHERE_PASSWORD=$vSpherePassword; export EKSA_VSPHERE_PASSWORD" >> ~/.profile
