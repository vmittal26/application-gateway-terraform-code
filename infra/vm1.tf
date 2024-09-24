



# Public IP
resource "azurerm_public_ip" "vm1-ip" {
  name                = "vm1-ip"
  location            = azurerm_resource_group.app-gateway.location
  resource_group_name = azurerm_resource_group.app-gateway.name
  allocation_method   = "Static"
  sku                 = "Standard"  # Standard SKU
}

# Network Interface
resource "azurerm_network_interface" "vm1" {
  name                = "vm1-nic"
  location            = azurerm_resource_group.app-gateway.location
  resource_group_name = azurerm_resource_group.app-gateway.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1-ip.id  # Assign the public IP to the NIC
  }
}

# Network Security Group (optional but recommended)
resource "azurerm_network_security_group" "vm1-nsg" {
  name                = "vm1-nsg"
  location            = azurerm_resource_group.app-gateway.location
  resource_group_name = azurerm_resource_group.app-gateway.name
}

# Allow SSH in the Network Security Group
resource "azurerm_network_security_rule" "vm1-ssh" {
  name                        = "vm1-allow-ssh"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.app-gateway.name
  network_security_group_name = azurerm_network_security_group.vm1-nsg.name
}

# Associate the NSG with the NIC
resource "azurerm_network_interface_security_group_association" "vm1" {
  network_interface_id      = azurerm_network_interface.vm1.id
  network_security_group_id = azurerm_network_security_group.vm1-nsg.id
}

# Ubuntu Virtual Machine
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1-vm"
  resource_group_name = azurerm_resource_group.app-gateway.name
  location            = azurerm_resource_group.app-gateway.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password =   "admin@261986"

  network_interface_ids = [
    azurerm_network_interface.vm1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "vm1-vm"
  disable_password_authentication = false
}
