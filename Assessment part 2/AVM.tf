### Resource Group ###
resource"azurerm_resource_group""zarmina-rg" {
 name     = var.rg_name
 location ="Australiaeast"
}
 
### Virtual network ###
resource"azurerm_virtual_network""zarmina-vnet" {
 name                = var.vnet_name
 address_space       =["10.10.0.0/16"]
 location            = azurerm_resource_group.zarmina-rg.location
 resource_group_name = azurerm_resource_group.zarmina-rg.name
}
 
### subnet-1 ###
resource"azurerm_subnet""subnet-1"{
 name                 = "subnet-1"
 resource_group_name  = azurerm_resource_group.zarmina-rg.name
 virtual_network_name = azurerm_virtual_network.zarmina-vnet.name
 address_prefixes     =["10.10.1.0/24"]
}


### subnet-2 for mysql ###
resource"azurerm_subnet""subnet-2" {
 name                 = "Db-Subnet"
 resource_group_name  = azurerm_resource_group.zarmina-rg.name
 virtual_network_name = azurerm_virtual_network.zarmina-vnet.name
 address_prefixes     =["10.10.2.0/24"]
 service_endpoints    =["Microsoft.Storage"]
 delegation {
   name ="fs"
   service_delegation {
     name ="Microsoft.DBforMySQL/flexibleServers"
     actions =[
       "Microsoft.Network/virtualNetworks/subnets/join/action",
     ]
   }
 }
}
 
### public-IP ###
resource"azurerm_public_ip""public_ip" {
 name = var.public_ip_name
 location = azurerm_resource_group.zarmina-rg.location
 resource_group_name = var.rg_name
 allocation_method ="Dynamic"
}

### Network Interface ###
resource"azurerm_network_interface""nic" {
 name                = var.nic_name
 location            = azurerm_resource_group.zarmina-rg.location
 resource_group_name = azurerm_resource_group.zarmina-rg.name
 
 ip_configuration {
   name                          ="internal"
   subnet_id                     = azurerm_subnet.subnet-1.id
   private_ip_address_allocation ="Dynamic"
   public_ip_address_id = azurerm_public_ip.public_ip.id
 }
}
 
### network security group ###
resource"azurerm_network_security_group""nsg" {
 name                = var.nsg_name
 location            = azurerm_resource_group.zarmina-rg.location
 resource_group_name = var.rg_name
 
 security_rule {
   name                       ="RDP"
   priority                   = 1000
   direction                  = "Inbound"
   access                     = "Allow"
   protocol                   = "Tcp"
   source_port_range          = "*"
   destination_port_range     ="3389"
   source_address_prefix      ="*"
   destination_address_prefix ="*"
 }
}

### VM ###
resource"azurerm_windows_virtual_machine""vm" {
 name                = var.vm_name
 resource_group_name = var.rg_name
 location            = azurerm_resource_group.zarmina-rg.location
 size                = "Standard_B1s"
 admin_username      ="Zarmina"
 admin_password      ="Aspire2100"
 network_interface_ids =[
   azurerm_network_interface.nic.id,
 ]
 
 os_disk {
   caching              = "ReadWrite"
   storage_account_type ="Standard_LRS"
 }
 
 source_image_reference {
   publisher ="MicrosoftWindowsServer"
   offer     ="WindowsServer"
   sku       ="2022-Datacenter-Azure-Edition"
   version   ="latest"
 }
}


### DNS zone ###
resource"azurerm_private_dns_zone""dnsZone" {
 name                = var.dnsZone_name
 resource_group_name = azurerm_resource_group.zarmina-rg.name
}


### Privste DNS ###
resource"azurerm_private_dns_zone_virtual_network_link""privateDns" {
 name                  = "LingdiIACvnetZone.com"
 private_dns_zone_name = azurerm_private_dns_zone.dnsZone.name
 virtual_network_id    = azurerm_virtual_network.zarmina-vnet.id
 resource_group_name   = azurerm_resource_group.zarmina-rg.name
}

### Azure Flexi Server ###
resource"azurerm_mysql_flexible_server""flexibleServer" {
 name                   = var.mysqlServerName
 resource_group_name    = azurerm_resource_group.zarmina-rg.name
 location               = azurerm_resource_group.zarmina-rg.location
 administrator_login    ="mysqlAdmin"
 administrator_password ="Aspire2@123"
 backup_retention_days  =7
 delegated_subnet_id    = azurerm_subnet.subnet-2.id
 private_dns_zone_id    = azurerm_private_dns_zone.dnsZone.id
 sku_name               = var.sku_name
 
 depends_on =[azurerm_private_dns_zone_virtual_network_link.privateDns]
}


 