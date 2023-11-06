#!/bin/bash
MDM_IP=172.26.2.9,172.26.2.11,172.26.2.49 dpkg -i EMC-ScaleIO-sdc-3.6-2000.117.Ubuntu.20.04.4.x86_64.deb
export REPO_USER=QNzgdxXix
export REPO_PASSWORD=Aw3wFAwAq3
export MDM_IP=172.26.2.9,172.26.2.11,172.26.2.49

cat <<EOF > /bin/emc/scaleio/scini_sync/driver_sync.conf
# Repository address, prefixed by protocol
#repo_address = sftp://localhost/path/to/repo/dir
repo_address = ftp://ftp.emc.com

# Repository user (valid for ftp/sftp protocol)
#repo_user = scini
repo_user = ${REPO_USER}

# Repository password (valid for ftp protocol)
#repo_password = scini
repo_password = ${REPO_PASSWORD}

# Local directory for modules
local_dir = /bin/emc/scaleio/scini_sync/driver_cache/

# User's RSA private key file (sftp protocol)
user_private_rsa_key = /etc/emc/scaleio/scini_sync/scini_key

# Repository host public key (sftp protocol)
repo_public_rsa_key = /etc/emc/scaleio/scini_sync/scini_repo_key.pub

# Should the fetched modules' signatures be checked [0, 1]
#module_sigcheck = 1
module_sigcheck = 0

# Should new public keys be fetched automatically
auto_fetch_public_keys = 0

# EMC public signature key (needed when module_sigcheck is 1)
emc_public_gpg_key = /etc/emc/scaleio/scini_sync/emc_key.pub

# Sync pattern (regular expression) for massive retrieve
sync_pattern = .*
EOF
touch /etc/emc/scaleio/scini_test.txt
/bin/emc/scaleio/scini_sync/driver_sync.sh scini retrieve Ubuntu20.04/3.6.2000.117/5.4.0-166-generic
systemctl restart scini
systemctl status scini
sleep 20
cat <<EOF > /etc/emc/scaleio/set_scini_initiator.sh
#!/bin/bash
if ls -al /etc/emc/scaleio | grep scini_test.txt; then
exit
else
echo -e "test" > /etc/emc/scaleio/scini_test.txt
export uuid=\$(uuidgen)
export MDM_IP=172.26.2.9,172.26.2.11,172.26.2.49
echo -e "ini_guid \$uuid\nmdm ${MDM_IP}" > /etc/emc/scaleio/drv_cfg.txt
sleep 10
systemctl restart scini
fi
EOF

chmod +x /etc/emc/scaleio/set_scini_initiator.sh
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

sudo systemctl daemon-reload
sudo systemctl enable set_scini_initiator.service
sudo systemctl start set_scini_initiator.service
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sudo service ssh restart
sudo chpasswd <<<"root:change-me"
sudo chpasswd <<<"ubuntu:change-me"
