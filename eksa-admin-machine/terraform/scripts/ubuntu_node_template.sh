#!/bin/bash
vsphere_content_library=eks-anywhere-template-$RANDOM
govc library.create "$vsphere_content_library"
sed -i "s/vsphere_content_library/$vsphere_content_library/g" $HOME/vsphere-connection.json
image-builder build --os ubuntu --hypervisor vsphere --release-channel 1-21 --vsphere-config $HOME/vsphere-connection.json
sudo -Hiu ubuntu eksctl anywhere download artifacts
sudo -Hiu ubuntu tar -xzf eks-anywhere-downloads.tar.gz
export eksd_release_tag=$(file=$(sudo -Hiu ubuntu ls eks-anywhere-downloads/1.21/eks-distro/ | grep kubernetes) | \
echo $file| rev | awk -v FS='.' '{print $2}' | rev)
export vsphere_templates_folder_full_path=/vsphere_datacenter/vm/vsphere_templates_folder
cp ubuntu.ova ubuntu-2004-kube-v1.21.14.ova
govc library.import $vsphere_content_library /home/image-builder/ubuntu-2004-kube-v1.21.14.ova
govc library.deploy -pool Test -folder $vsphere_templates_folder_full_path /$vsphere_content_library/ubuntu-2004-kube-v1.21.14 ubuntu-2004-kube-v1.21.14
govc snapshot.create -vm ubuntu-2004-kube-v1.21.14 root
govc vm.markastemplate ubuntu-2004-kube-v1.21.14
govc tags.create -c os os:ubuntu
govc tags.category.create -t VirtualMachine eksdRelease
govc tags.attach os:ubuntu /$vsphere_templates_folder_full_path/ubuntu-2004-kube-v1.21.14
govc tags.attach eksdRelease:$eksd_release_tag /$vsphere_templates_folder_full_path/ubuntu-2004-kube-v1.21.14
govc library.rm "$vsphere_content_library"
