#!/bin/bash
export mdmIP=mdm-ip-addresses
#
sudo apt update -y
sudo apt install tree libaio1 linux-image-6.5.0-21-generic libnuma1 uuid-runtime nano sshpass unzip -y
#
cd /home/ubuntu
#
cp /etc/default/grub /etc/default/grub.backup
# In the above list of packages, we have installed 6.5.0-21-generic linux kernel for ubuntu 22.04
# This ensures compatability with the scini driver files available in Dell FTP site
# Below we are setting the grub to boot from generic kernel version
#
sed -i \
s/GRUB_DEFAULT=0/GRUB_DEFAULT='"Advanced options for Ubuntu>Ubuntu, with Linux 6.5.0-21-generic"'/g \
/etc/default/grub
sudo update-grub
#
#
cd /home/ubuntu
wget https://pflex-packages.s3.eu-west-1.amazonaws.com/pflex-45/Software_Only_Complete_4.5.0_287/PowerFlex_4.5.0.287_SDCs_for_manual_install.zip
unzip PowerFlex_4.5.0.287_SDCs_for_manual_install.zip
cd PowerFlex_4.5.0.287_SDCs_for_manual_install/
unzip PowerFlex_4.5.0.287_Ubuntu22.04_SDC.zip
cd PowerFlex_4.5.0.287_Ubuntu22.04_SDC/
tar -xvf EMC-ScaleIO-sdc-4.5-0.287.Ubuntu.22.04.x86_64.tar
./siob_extract EMC-ScaleIO-sdc-4.5-0.287.Ubuntu.22.04.x86_64.siob
MDM_IP=${mdmIP} dpkg -i EMC-ScaleIO-sdc-4.5-0.287.Ubuntu.22.04.x86_64.deb
#
sudo wget https://raw.githubusercontent.com/thecloudgarage/eks-anywhere/main/powerflex/driver_sync.conf -P /bin/emc/scaleio/scini_sync
#
sudo /bin/emc/scaleio/scini_sync/driver_sync.sh scini retrieve Ubuntu22.04/4.5.0.287/6.5.0-21-generic/
#
sudo systemctl restart scini
#
sleep 20
#
export uuid=$(uuidgen)
echo -e "ini_guid $uuid\nmdm ${mdmIP}" > /etc/emc/scaleio/drv_cfg.txt
sleep 10
sudo systemctl restart scini
#
sudo sed -i 's/^Include \/etc.*/#Include \/etc\/ssh\/sshd_config.d\/*.conf/g' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo service ssh restart
#
sudo chpasswd <<<"root:ubuntu"
sudo chpasswd <<<"ubuntu:ubuntu"
#
reboot
