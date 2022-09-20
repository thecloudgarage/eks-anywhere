variable "vsphere_user" {
  description = "vSphere username"
  type        = string
  default     = "vsphere_username"
}
variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
  default     = "vsphere_password"
}
variable "vsphere_server" {
  description = "vSphere server ip or fqdn"
  type        = string
  default     = "vc.iac.ssc"
}
variable "vsphere_datacenter" {
  description = "vSphere datacenter name"
  type        = string
  default     = "IAC-SSC"
}
variable "vsphere_resource_pool" {
  description = "vSphere existing resource pool to be used for this virtual machine"
  type        = string
  default     = "Test"
}
variable "vsphere_datastore" {
  description = "vSphere datastore name"
  type        = string
  default     = "CommonDS"
}
variable "vsphere_network" {
    description = "vSphere network to be used for the virtual machine"
    type        = string
    default     = "iac_pg"
}
variable "existing_virtual_machine_template_name" {
    description = "Template name to be used for this virtual machine. Must be an existing template located in Templates folder"
    type        = string
    default     = "ubuntu-2004-desktop"
}
variable "virtual_machine_folder_name" {
    description = "Existing Folder name where the virtual machine will be configured"
    type        = string
    default     = "test-eks-anywhere"
}
variable "virtual_machine_name" {
  description = "Name of the virtual machine"
  type = string
  default = "eksa-admin"
}
variable "virtual_machine_vcpu_count" {
  description = "virtual machine vCPU count"
  type        = number
  default     = 4
}
variable "virtual_machine_memory" {
  description = "virtual machine Memory"
  type        = number
  default     = 16384
}
variable "virtual_machine_disk0_size" {
  description = "virtual machine disk0 size"
  type = number
  default = 100
}
variable "virtual_machine_root_password" {
  description = "virtual machine password"
  type        = string
  sensitive   = true
  default     = "ubuntu"
}
variable "virtual_machine_static_ip_address" {
    description = "Static IP address to be used for the virtual machine"
    type        = string
    default     = "172.24.165.50"
}
variable "virtual_machine_subnet_mask" {
    description = "virtual machine subnet mask"
    type        = number
    default     = 22
}
variable "dns_servers" {
  description = "List of comma separated DNS server values"
  type        = list
  default     = ["172.24.164.10"]
}
variable "virtual_machine_domain_name" {
    description = "Domain name to be associated with the virtual machine"
    type        = string
    default     = "iac.ssc"
}
variable "ipv4_gateway" {
  description = "IPv4 gateway for the virtual machine"
  type        = string
  default     = "172.24.164.1"
}
