#!/bin/bash
sudo apt update -y
sudo apt install open-iscsi tree libaio1 linux-image-extra-virtual libnuma1 uuid-runtime nano sshpass unzip -y
sudo systemctl enable --now iscsid 
cd /usr/local/share/ca-certificates
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
cat <<EOF > /etc/iscsi/set_iscsi_initiator.sh
#!/bin/bash
echo -e InitiatorName=iqn.1993-08.org.debian:01:$(hostname) > /etc/iscsi/initiatorname.iscsi
systemctl restart iscsid
EOF
chmod +x /etc/iscsi/set_iscsi_initiator.sh
cd /etc/systemd/system
cat <<EOF > set_iscsi_initiator.service
[Unit]
Description=Set unique iqn for ISCSI
After=network.target

[Service]
ExecStart=/etc/iscsi/set_iscsi_initiator.sh
Restart=on-failure
User=root
Group=root
Type=simple

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable set_iscsi_initiator.service
sudo systemctl start set_iscsi_initiator.service

cd /home/ubuntu

#wget https://anhalwaysfortest.s3.amazonaws.com/EMC-ScaleIO-sdc-3.6-2000.117.Ubuntu.20.04.4.x86_64.tar
#tar -xvf EMC-ScaleIO-sdc-3.6-2000.117.Ubuntu.20.04.4.x86_64.tar
#./siob_extract EMC-ScaleIO-sdc-3.6-2000.117.Ubuntu.20.04.4.x86_64.siob
cp /etc/default/grub /etc/default/grub.backup
sed -i \
s/GRUB_DEFAULT=0/GRUB_DEFAULT='"gnulinux-advanced-d5068d1a-ca5c-4559-bef1-0a480bcb3807>gnulinux-5.4.0-166-generic-advanced-d5068d1a-ca5c-4559-bef1-0a480bcb3807"'/g \
/etc/default/grub
sudo update-grub
reboot
