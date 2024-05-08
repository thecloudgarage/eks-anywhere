#!/bin/bash
#read -p 'vSphere Datacenter name: ' vsphere_datacenter
read -p 'vSphere Default Templates folder, e.g. Templates: ' vsphere_templates_folder
read -p 'Final name for EKS-A ubuntu node template, e.g. ubuntu-2004-kube-v1.25: ' ubuntu_template_name
read -p 'vSphere Resource pool name, e.g. Test: ' vsphere_resource_pool
sudo -Hiu ubuntu rm -rf eks-anywhere-downloads
sudo -Hiu ubuntu rm -rf eks-anywhere-downloads.tar.gz
sudo -Hiu ubuntu eksctl anywhere download artifacts
sudo -Hiu ubuntu tar -xzf eks-anywhere-downloads.tar.gz
file=$(sudo -Hiu ubuntu ls /home/ubuntu/eks-anywhere-downloads/1.29/eks-distro/ | grep kubernetes)
export eksd_release_tag=$(echo $file | rev | awk -v FS='.' '{print $2}' | rev)
echo $eksd_release_tag
vsphere_content_library=eks-anywhere-template-$RANDOM
govc library.create -dc=$GOVC_DATACENTER "$vsphere_content_library"
sed -i "s/vsphere_content_library/$vsphere_content_library/g" $HOME/vsphere-connection.json
image-builder build --os ubuntu --hypervisor vsphere --release-channel 1-29 --vsphere-config $HOME/vsphere-connection.json
export vsphere_templates_folder_full_path=/$GOVC_DATACENTER/vm/$vsphere_templates_folder
mv $HOME/ubuntu.ova $HOME/$ubuntu_template_name.ova
govc library.import $vsphere_content_library $HOME/$ubuntu_template_name.ova
govc library.deploy -dc=$GOVC_DATACENTER -pool $vsphere_resource_pool -folder $vsphere_templates_folder_full_path /$vsphere_content_library/$ubuntu_template_name $ubuntu_template_name
govc snapshot.create -dc=$GOVC_DATACENTER -vm $ubuntu_template_name root
govc vm.markastemplate -dc=$GOVC_DATACENTER $ubuntu_template_name
govc tags.category.create -t VirtualMachine os 2> /dev/null
govc tags.create -c os os:ubuntu 2> /dev/null
govc tags.category.create -t VirtualMachine eksdRelease 2> /dev/null
govc tags.create -c eksdRelease eksdRelease:$eksd_release_tag 2> /dev/null
govc tags.attach os:ubuntu $vsphere_templates_folder_full_path/$ubuntu_template_name
govc tags.attach eksdRelease:$eksd_release_tag $vsphere_templates_folder_full_path/$ubuntu_template_name
govc library.rm "$vsphere_content_library"
sed -i "s/$vsphere_content_library/vsphere_content_library/g" $HOME/vsphere-connection.json
echo "$ubuntu_template_name template is created successfully and is located in $vsphere_templates_folder"
