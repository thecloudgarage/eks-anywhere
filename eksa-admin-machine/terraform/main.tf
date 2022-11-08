# Basic configuration withour variables

# Define authentification configuration
provider "vsphere" {
  # If you use a domain set your login like this "MyDomain\\MyUser"
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

#### RETRIEVE DATA INFORMATION ON VCENTER ####

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_resource_pool" "pool" {
  # If you haven't resource pool, put "Resources" after cluster name
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# NOTE: YOU WILL NEED AN EXISTING TEMPLATE IN THE TEMPLATES FOLDER. Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = var.existing_virtual_machine_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

#### VM CREATION ####

# Set vm parameters
resource "vsphere_virtual_machine" "vm-one" {
  name             = var.virtual_machine_name
  folder           = var.virtual_machine_folder_name
  num_cpus         = var.virtual_machine_vcpu_count
  memory           = var.virtual_machine_memory
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  # Set network parameters
  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Use a predefined vmware template has main disk
  disk {
    label       = "disk0"
    size        = var.virtual_machine_disk0_size
    thin_provisioned = "false"
  }
  # Note as per vsphere provider documentation dns servers are provided in the global configuration and not under network interface
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = var.virtual_machine_name
        domain    = var.virtual_machine_domain_name
      }

      network_interface {
        ipv4_address    = var.virtual_machine_static_ip_address
        ipv4_netmask    = var.virtual_machine_subnet_mask
      }

      ipv4_gateway = var.ipv4_gateway
      dns_server_list = var.dns_servers
    }
  }
}

# First step is to bootstrap the virtual machine with docker, docker-compose, jq, homebrew
# Note we are creating a sleep cycle via time_sleep resource, else terraform remote-exec might have issues before the VM is ready
# The bootstrap script will also add the image-builder sudo user
resource "time_sleep" "wait_for_vm" {
  create_duration = "20s"
  depends_on = [vsphere_virtual_machine.vm-one]
}
resource "null_resource" "virtual_machine_bootstrapper" {
  depends_on = [time_sleep.wait_for_vm]
  connection {
      type     = "ssh"
      user     = "ubuntu"
      password = var.virtual_machine_root_password
      host     = var.virtual_machine_static_ip_address
  }
  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "echo ${var.virtual_machine_root_password} | sudo -S apt-get update -y",
      "sudo apt-get install git -y",
      "cd $HOME && git clone https://github.com/thecloudgarage/eks-anywhere.git",
      "find $HOME/eks-anywhere/ -name \"*.sh\" -type f -print0 | xargs -0 chmod +x",
      "sed -i 's/virtual_machine_root_password/${var.virtual_machine_root_password}/g' $HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/eksa-admin-machine-bootstrap-utils.sh",
      "$HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/eksa-admin-machine-bootstrap-utils.sh",
      "sleep 10"
    ]
  }
}

# Hereon, we will install important packages that are generally used for Kubernetes including eks-anywhere
# We are also inducing a time sleep just in case. This time sleep will depend on the completion of previous null resource used for bootstrapping

resource "time_sleep" "wait_for_vm_to_finish_bootstrap" {
  create_duration = "20s"
  depends_on = [null_resource.virtual_machine_bootstrapper]
}
resource "null_resource" "eks_anywhere_provisioner" {
  depends_on = [time_sleep.wait_for_vm_to_finish_bootstrap]
  connection {
      type     = "ssh"
      user     = "ubuntu"
      password = var.virtual_machine_root_password
      host     = var.virtual_machine_static_ip_address
  }
  // Without the first eval line, the brew installations will fail
  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "echo ${var.virtual_machine_root_password} | sudo -S touch temp.txt",
      "eval \"$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"",
      "brew install aws/tap/eks-anywhere",
      "brew tap hashicorp/tap",
      "brew install hashicorp/tap/terraform",
      "brew install argocd",
      "brew install fluxcd/tap/flux",
      "sleep 10"
    ]
  }
}

# Next we will set the vSphere credentials in ubuntu profile for creating EKS Anywhere clusters
# Note the use of var for inline commands and also reflect on how we are escaping double quoted string with backslashes
resource "null_resource" "set_vsphere_credentials_in_profile" {
  depends_on = [null_resource.eks_anywhere_provisioner]
  connection {
      type     = "ssh"
      user     = "ubuntu"
      password = var.virtual_machine_root_password
      host     = var.virtual_machine_static_ip_address
  }
  // The below will set the vsphere credentials in the ubuntu profile for EKSA cluster provisioning
  provisioner "remote-exec" {
    inline = [
      "sed -i '/^EKSA_VSPHERE_/d' ~/.profile",
      "echo \"EKSA_VSPHERE_USERNAME=${var.vsphere_user}; export EKSA_VSPHERE_USERNAME\" >> ~/.profile",
      "echo \"EKSA_VSPHERE_PASSWORD=${var.vsphere_password}; export EKSA_VSPHERE_PASSWORD\" >> ~/.profile",
    ]
  }
}

# Next we will install govc, image-builder and related utilities
resource "null_resource" "install_image_builder_and_govc" {
  depends_on = [null_resource.set_vsphere_credentials_in_profile]
  connection {
      type     = "ssh"
      user     = "image-builder"
      password = var.virtual_machine_root_password
      host     = var.virtual_machine_static_ip_address
  }
  // The below will perform the necessary actions to install govc and image-builder
  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "echo ${var.virtual_machine_root_password} | sudo -S ls",
      "cd /home/image-builder",
      "echo \"GOVC_URL=${var.vsphere_server}; export GOVC_URL\" >> ~/.profile",
      "echo \"GOVC_USERNAME=${var.vsphere_user}; export GOVC_USERNAME\" >> ~/.profile",
      "echo \"GOVC_PASSWORD=${var.vsphere_password}; export GOVC_PASSWORD\" >> ~/.profile",
      "echo \"GOVC_INSECURE=true; export GOVC_INSECURE\" >> ~/.profile",
      "echo \"GOVC_DATASTORE=${var.vsphere_datastore}; export GOVC_DATASTORE\" >> ~/.profile",
      "git clone https://github.com/thecloudgarage/eks-anywhere.git",
      "find $HOME/eks-anywhere/ -name \"*.sh\" -type f -print0 | xargs -0 chmod +x",
      "cp $HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/vsphere-connection.json $HOME/vsphere-connection.json",
      "$HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/image_builder_govc.sh",
      "sleep 10"
    ]
  }
}

resource "time_sleep" "wait_for_image_builder_govc" {
  create_duration = "20s"
  depends_on = [null_resource.install_image_builder_and_govc]
}

# Next we will set the vsphere connection settings for image-builder process
resource "null_resource" "set_image_builder_vsphere_connection" {
  depends_on = [time_sleep.wait_for_image_builder_govc]
  connection {
      type     = "ssh"
      user     = "image-builder"
      password = var.virtual_machine_root_password
      host     = var.virtual_machine_static_ip_address
      script_path = "/home/image-builder/terraform_provisioner_%RAND%.sh"
  }
  // The below will set the vsphere configureation for image-builder profile
  provisioner "remote-exec" {
    inline = [
      "sed -i 's/vsphere_compute_cluster/${var.vsphere_compute_cluster}/g' $HOME/vsphere-connection.json",
      "sed -i 's/vsphere_datacenter/${var.vsphere_datacenter}/g' $HOME/vsphere-connection.json",
      "sed -i 's/vsphere_datastore/${var.vsphere_datastore}/g' $HOME/vsphere-connection.json",
      "sed -i 's/vsphere_templates_folder/${var.vsphere_templates_folder}/g' $HOME/vsphere-connection.json",
      "sed -i 's/vsphere_network/${var.vsphere_network}/g' $HOME/vsphere-connection.json",
      "sed -i 's/vsphere_password/${var.vsphere_password}/g' $HOME/vsphere-connection.json",
      "sed -i 's/vsphere_resource_pool/${var.vsphere_resource_pool}/g' $HOME/vsphere-connection.json",
      "sed -i 's/vsphere_user/${var.vsphere_user}/g' $HOME/vsphere-connection.json",
      "sed -i 's/vsphere_server/${var.vsphere_server}/g' $HOME/vsphere-connection.json",
      "cp $HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/ubuntu_node_template* $HOME/",
    ]
  }
}

