resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.app-gateway.name
  location            = azurerm_resource_group.app-gateway.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "vm" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.app-gateway.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app-gateway" {
  name                 = "app-gateway"
  resource_group_name  = azurerm_resource_group.app-gateway.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [ azurerm_virtual_network.vnet ]
}
