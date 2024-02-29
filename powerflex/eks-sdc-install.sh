#!/bin/bash
export mdmIP=mdm-ip-addresses
#
sudo apt update -y
sudo apt install tree libaio1 linux-image-5.4.0-167-generic libnuma1 uuid-runtime nano sshpass unzip -y
#
cd /usr/local/share/ca-certificates
#
cat <<EOF > thecloudgarage.crt
-----BEGIN CERTIFICATE-----
MIID4jCCAsqgAwIBAgIUXtFYp7Iq2sGhKdpX0wbWCTemlGUwDQYJKoZIhvcNAQEL
BQAwcDELMAkGA1UEBhMCSU4xCzAJBgNVBAgMAk1IMQ8wDQYDVQQHDAZNdW1iYWkx
DjAMBgNVBAoMBXN0YWNrMQ8wDQYDVQQLDAZkZXZvcHMxIjAgBgNVBAMMGSoub2lk
Yy50aGVjbG91ZGdhcmFnZS5jb20wHhcNMjMwNjA1MTAxMTQ3WhcNMjUwNjA0MTAx
MTQ3WjBwMQswCQYDVQQGEwJJTjELMAkGA1UECAwCTUgxDzANBgNVBAcMBk11bWJh
aTEOMAwGA1UECgwFc3RhY2sxDzANBgNVBAsMBmRldm9wczEiMCAGA1UEAwwZKi5v
aWRjLnRoZWNsb3VkZ2FyYWdlLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBANfTqtO7MQhwneQfVa0GKMTEP0N9340r8vANvjxMMTbTOxXjQwwEo+w2
9bYBual6AoOsXwvcKDUT2lTpQArrdomwI0llKBpbugid922XPtx7GauXYeE2D/oV
hvEzEB1VC5pmc0JjH3P/PKiWJp5AmB7x6sYKQ4y4k56xYrlYw7LEV81pPlh7dvpA
+vzdYOXTUGb/9rLHbuTHwOW9+x6ezg/gHuWjLtHKCzF8/bbU941a6wLvNpvoYhRE
34eXXCwdUHEU9Ux6HWX7DIQ1mAqyCRS9etqQSpCO4cuh3t5u48zC8hY/iWe8Zm7y
RTe7Wf0lXY7ONizWKyJaHgs9CNLRt1sCAwEAAaN0MHIwCwYDVR0PBAQDAgWgMBMG
A1UdJQQMMAoGCCsGAQUFBwMBME4GA1UdEQRHMEWCEnRoZWNsb3VkZ2FyYWdlLmNv
bYIUKi50aGVjbG91ZGdhcmFnZS5jb22CGSoub2lkYy50aGVjbG91ZGdhcmFnZS5j
b20wDQYJKoZIhvcNAQELBQADggEBAAimXk4BfIeVEUQl2zBdsSF54cN2I6hQpqg5
YNSbvwlZ9oKTZ7IcKDQqpfNp3nFyo7K4uHftjnQhJDb/o2ZmmgzBPf1PQXp+/oL8
pISBqltBEFlDR9CMgulVInVy5+CCZMN2P66RTvGvmRl9gLrKhuMdoRm7Equ7jDIK
xbKXRbrRCH0EMYMG3hrLntFZ9Oj0MI9/Vn6jiM9J/e7ZLJY2HydWAole14Pm7Dn6
nSgi7JcL6A9KnKrLf+MMtQAp8Yhb9smhAGbU/ZEGvyyzbeEbbvuFXVpizvPN/mg0
ETuo/amuh+Dr89yv4eenn/fZH6+mAngZz5KusLUGWDRNT8Nba/I=
-----END CERTIFICATE-----
EOF
sudo update-ca-certificates 
#
cd /home/ubuntu
#
cp /etc/default/grub /etc/default/grub.backup
# In the above list of packages, we have installed 5.4.0-167-generic linux kernel for ubuntu 20.04
# This ensures compatability with the scini driver files available in Dell FTP site
# Below we are setting the grub to boot from 167 generic kernel version
sed -i \
s/GRUB_DEFAULT=0/GRUB_DEFAULT='"Advanced options for Ubuntu>Ubuntu, with Linux 5.4.0-167-generic"'/g \
/etc/default/grub
sudo update-grub
#
#
cd /home/ubuntu
wget https://pflex-packages.s3.eu-west-1.amazonaws.com/pflex-45/Software_Only_Complete_4.5.0_287/PowerFlex_4.5.0.287_SDCs_for_manual_install.zip
unzip PowerFlex_4.5.0.287_SDCs_for_manual_install.zip
cd PowerFlex_4.5.0.287_SDCs_for_manual_install/
unzip PowerFlex_4.5.0.287_Ubuntu20.04_SDC.zip
cd PowerFlex_4.5.0.287_Ubuntu20.04_SDC/
tar -xvf EMC-ScaleIO-sdc-4.5-0.287.Ubuntu.20.04.4.x86_64.tar
./siob_extract EMC-ScaleIO-sdc-4.5-0.287.Ubuntu.20.04.4.x86_64.siob
MDM_IP=${mdmIP} dpkg -i EMC-ScaleIO-sdc-4.5-0.287.Ubuntu.20.04.4.x86_64.deb
#
# Due to a known issue, the automated scini install will fail for ubuntu OS.
# So we render a driver sync configuration to download the scini.tar from dell FTP site based on the respective kernel version
#
sudo wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/driver_sync.conf -P /bin/emc/scaleio/scini_sync
#
sudo /bin/emc/scaleio/scini_sync/driver_sync.sh scini retrieve Ubuntu20.04/4.5.0.287/5.4.0-167-generic/
#
systemctl restart scini
#
sleep 20
#
cat <<EOF > /etc/emc/scaleio/set_scini_initiator.sh
#!/bin/bash
if ls -al /etc/emc/scaleio | grep scini_test.txt; then
systemctl restart scini
exit
else
echo -e "test" > /etc/emc/scaleio/scini_test.txt
export uuid=\$(uuidgen)
echo -e "ini_guid \$uuid\nmdm ${mdmIP}" > /etc/emc/scaleio/drv_cfg.txt
sleep 10
systemctl restart scini
fi
EOF
#
chmod +x /etc/emc/scaleio/set_scini_initiator.sh
#
cd /etc/systemd/system/
cat <<EOF > set_scini_initiator.service
# Copy the below contents in the service file
[Unit]
Description=Set unique uuid for powerflex sdc
After=network.target
[Service]
ExecStart=/etc/emc/scaleio/set_scini_initiator.sh
Restart=on-failure
User=root
Group=root
Type=oneshot
[Install]
WantedBy=multi-user.target
EOF
#
sudo systemctl daemon-reload
sudo systemctl enable set_scini_initiator.service
sudo systemctl start set_scini_initiator.service
#
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo service ssh restart
#
sudo chpasswd <<<"root:ubuntu"
sudo chpasswd <<<"ubuntu:ubuntu"
#
reboot
