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
  name             = "ubuntu"
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
    size        = "100"
    thin_provisioned = "false"
  }
  # Note as per vsphere provider documentation dns servers are provided in the global configuration and not under network interface
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "ubuntu"
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
      "echo ${var.virtual_machine_root_password} | sudo -S apt-get update -y",
      "sudo apt-get install git -y",
      "cd $HOME && git clone https://github.com/thecloudgarage/eks-anywhere.git",
      "chmod +x $HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/*.sh",
      "$HOME/eks-anywhere/eksa-admin-machine/terraform/scripts/eksa-admin-machine-bootstrap-utils.sh",
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
      "echo ${var.virtual_machine_root_password} | sudo -S apt-get update -y",
      "eval \"$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"",
      "brew install aws/tap/eks-anywhere",
      "brew tap hashicorp/tap",
      "brew install hashicorp/tap/terraform",
      "brew install argocd",
      "brew install fluxcd/tap/flux",
      "cd $HOME && sudo apt-get update -y",
      "curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash",
      "sudo apt -y install sshpass",
    ]
  }
}
