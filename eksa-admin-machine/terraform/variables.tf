variable "vsphere_user" {
  description = "vSphere username"
  type        = string
  default     = "username"
}
variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  default     = "password"
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
variable "virtual_machine_vcpu_count" {
  description = "vSphere username"
  type        = number
  default     = 4
}
variable "virtual_machine_memory" {
  description = "vSphere username"
  type        = number
  default     = 16384
}
variable "virtual_machine_root_password" {
  description = "vSphere username"
  type        = string
  sensitive   = true
  default     = "password"
}
variable "virtual_machine_static_ip_address" {
    description = "vSphere username"
    type        = string
    default     = "172.24.165.50"
}
variable "virtual_machine_subnet_mask" {
    description = "vSphere username"
    type        = number
    default     = 22
}
variable "var.dns_servers" {
  description = "List of comma separated DNS server values"
  type        = list
  default     = ["172.24.164.10"]
}
variable "var.ip4_gateway" {
  description = "vSphere username"
  type        = string
  default     = "172.24.164.1"
}
