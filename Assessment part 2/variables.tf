### variables ###

variable"rg_name" {
 description ="Name of resource group"
 default = "zarminaIAC-rg"
}
 
variable"nic_name" {
 description ="Name of network interface"
 default = "zarminaIAC-nic"
 
}
 
variable"nsg_name" {
 description ="Name of network security group"
 default = "zarminaIAC-nsg"
}
 
variable"public_ip_name" {
 description ="Name of public ip address"
 default = "zarminaIAC-public-ip"
}
 
variable"vnet_name" {
 description ="Name of virtual network"
 default = "zarminaIAC-vnet"
}
 
variable"vm_name" {
 description ="Name of virtual machine"
 default = "zarminaIAC-vm"
}
 
variable"dnsZone_name" {
 description ="Name of DNS zone"
 default = "zarminaIAC.mysql.database.azure.com"
}
 
variable"mysqlServerName" {
 description ="Name of mysql server name"
 default = "zarminamysqlfs-iac601"
}
 
variable"sku_name" {
 description ="Name of mysql flexible server sku"
 default = "GP_Standard_D2ds_v4"
}

