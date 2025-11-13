```
export virtual_machine_root_password=ubuntu
sudo apt-get update -y
sudo apt-get install git -y
cd $HOME && git clone https://github.com/thecloudgarage/eks-anywhere.git",
find $HOME/eks-anywhere/ -name \"*.sh\" -type f -print0 | xargs -0 chmod +x
cp $HOME/eks-anywhere/cluster-ops/*.sh $HOME/
sed -i 's/virtual_machine_root_password/$virtual_machine_root_password/g' $HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/eksa-admin-machine-bootstrap-utils.sh
$HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/eksa-admin-machine-bootstrap-utils.sh
```
