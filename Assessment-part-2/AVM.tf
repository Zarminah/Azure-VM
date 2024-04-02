

resource "azurerm_resource_group" "RG" {
  name     = "ZarminaIAC-rg"
  location = "Australiaeast"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ZarminaIAC-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_subnet" "internal" {
 name                 = "internal"
   resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
 name                = "ZarminaIAC-nic"
 location            = azurerm_resource_group.RG.location
 resource_group_name = azurerm_resource_group.RG.name

 ip_configuration {
       name                          = "ZarminaIAC-Public-ip"
    subnet_id                     = azurerm_subnet.internal.id
     private_ip_address_allocation = "Dynamic"
   }
}

 resource "azurerm_virtual_machine" "VM" {
   name                  = "ZarminaIAC-vm"
  location              = azurerm_resource_group.RG.location
   resource_group_name   = azurerm_resource_group.RG.name
   network_interface_ids = [azurerm_network_interface.nic.id]
   vm_size               = "Standard_B1s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
   publisher = "Canonical"
   offer     = "0001-com-ubuntu-server-jammy"
   sku       = "22_04-lts"
   version   = "latest"
     }
 storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

  resource "azurerm_subnet" "sn" {
   name                 = "ZarminaIAC-sn"
   resource_group_name  = azurerm_resource_group.RG.name
   virtual_network_name = azurerm_virtual_network.vnet.name
 address_prefixes     = ["10.10.3.0/24"]
   service_endpoints    = ["Microsoft.Storage"]
   delegation {
     name = "fs"
     service_delegation {
       name = "Microsoft.DBforMySQL/flexibleServers"
       actions = [
         "Microsoft.Network/virtualNetworks/subnets/join/action",
       ]
    }
   }
}


resource "azurerm_private_dns_zone" "dns-zone" {
  name                = "zarminazIAC.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "DNs" {
  name                  = "ZarminaVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.RG.name
}

resource "azurerm_mysql_flexible_server" "Mysql" {
  name                   = "zarmina-mysqlfs-iac601"
  resource_group_name    = azurerm_resource_group.RG.name
  location               = azurerm_resource_group.RG.location
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.sn.id
  private_dns_zone_id    = azurerm_private_dns_zone.dns-zone.id
  sku_name               = "GP_Standard_D2ds_v4"
  #zone = 1

  depends_on = [azurerm_private_dns_zone_virtual_network_link.DNs]
}

