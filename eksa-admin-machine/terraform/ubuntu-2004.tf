# Basic configuration withour variables

# Define authentification configuration
provider "vsphere" {
  # If you use a domain set your login like this "MyDomain\\MyUser"
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_ip_or_fqdn

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

#### RETRIEVE DATA INFORMATION ON VCENTER ####

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_resource_pool" "pool" {
  # If you haven't resource pool, put "Resources" after cluster name
  name          = var.vsphere_resourcepool
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_data_store
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = var.vsphere_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# NOTE: YOU WILL NEED AN EXISTING TEMPLATE IN THE TEMPLATES FOLDER. Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_virtual_machine_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

#### VM CREATION ####

# Set vm parameters
resource "vsphere_virtual_machine" "vm-one" {
  name             = "ubuntu"
  folder           = var.virtual_machine_folder_name
  num_cpus         = 4
  memory           = 16384
  datastore_id     = data.vsphere_datastore.datastore.id
#  host_system_id   = data.vsphere_host.host.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  # Set network parameters
  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # Use a predefined vmware template has main disk
  disk {
    label       = "disk0"
    size        = "100"
    thin_provisioned = "false"
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "ubuntu"
        domain    = var.virtual_machine_domain_name
      }

      network_interface {
        ipv4_address    = "172.24.165.50"
        ipv4_netmask    = 22
        dns_server_list = ["172.24.164.10"]
      }

      ipv4_gateway = "172.24.164.1"
    }
  }

  # Execute script on remote vm after this creation
  # Execute script on remote vm after this creation
  provisioner "remote-exec" {
    script = "scripts/example-script.sh"
    connection {
      type     = "ssh"
      user     = "ubuntu"
      password = var.virtual_machine_root_password
      host     = "172.24.165.50"
    }
  }
}
