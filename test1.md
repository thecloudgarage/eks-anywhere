echo -e "iface.transport_name = tcp\niface.net_ifacename = eth0" | sudo tee /etc/iscsi/ifaces/iface0
sudo vi /etc/sysconfig/network/ifcfg-eth0

DEVICE=eth0
NAME=eth0
STARTMODE=auto
BOOTPROTO=static
IPADDR=10.204.111.31
NETMASK=255.255.254.0
 
sudo vi /etc/sysconfig/network/routes
default 10.204.110.1 - eth0
 
sudo vi /etc/sysconfig/network/config
NETCONFIG_DNS_STATIC_SEARCHLIST="edub.csc"
NETCONFIG_DNS_STATIC_SERVERS="10.204.108.51"
 
# Change the root password, hostname and reboot
sudo passwd root
sudo hostnamectl set-hostname mc-mg-powerflex45-pfmp
sudo reboot

vi /etc/chrony.conf
pool pool.ntp.org iburst

# Install the Kubectl cli tools
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
 
# Disable the firewall
systemctl stop firewalld
systemctl disable firewalld
systemctl mask --now firewalld
 
# additional NIC's
vi /etc/sysconfig/network/ifcfg-eth1
 
NAME=''
BOOTPROTO='none'
STARTMODE='off'
ZONE=public
