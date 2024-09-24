resource "azurerm_public_ip" "app-gateway" {
  name                = "app-gateway-pip"
  resource_group_name = azurerm_resource_group.app-gateway.name
  location            = azurerm_resource_group.app-gateway.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_images_address_pool_name      = "${azurerm_resource_group.app-gateway.name}-images"
  backend_videos_address_pool_name      = "${azurerm_resource_group.app-gateway.name}-videos"
  frontend_port_name             = "${azurerm_resource_group.app-gateway.name}-feport"
  frontend_ip_configuration_name = "${azurerm_resource_group.app-gateway.name}-feip"
  http_setting_name              = "${azurerm_resource_group.app-gateway.name}-be-htst"
  listener_name                  = "${azurerm_resource_group.app-gateway.name}-server"
  request_routing_rule_images_name      = "${azurerm_resource_group.app-gateway.name}-images-rule"
  request_routing_rule_videos_name      = "${azurerm_resource_group.app-gateway.name}-videos-rule"
  redirect_configuration_name    = "${azurerm_resource_group.app-gateway.name}-rdrcfg"
}

resource "azurerm_application_gateway" "gateway" {
  name                = "app-gateway-appgateway"
  resource_group_name = azurerm_resource_group.app-gateway.name
  location            = azurerm_resource_group.app-gateway.location
  depends_on = [ azurerm_linux_virtual_machine.vm1 , azurerm_linux_virtual_machine.vm2]

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.app-gateway.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app-gateway.id
  }

  backend_address_pool {
    name = local.backend_images_address_pool_name
    ip_addresses = [azurerm_linux_virtual_machine.vm1.private_ip_address]
  }

  backend_address_pool {
    name = local.backend_videos_address_pool_name
    ip_addresses = [azurerm_linux_virtual_machine.vm2.private_ip_address]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

   url_path_map {
      name                               = "url-path-service-mapping"
      default_backend_address_pool_name  = local.backend_images_address_pool_name
      default_backend_http_settings_name = local.http_setting_name
      path_rule {
          name                       = "rule1"
          paths                      = ["/images/*"]
          backend_address_pool_name = local.backend_images_address_pool_name
          backend_http_settings_name = local.http_setting_name
      }
      path_rule {
          name                       = "rule2"
          paths                      = ["/videos/*"]
          backend_address_pool_name = local.backend_videos_address_pool_name
          backend_http_settings_name = local.http_setting_name
      }
      
  }
  request_routing_rule {
    name                       = local.request_routing_rule_images_name
    priority                   = 1
    rule_type                  = "PathBasedRouting"
    http_listener_name         = local.listener_name
    url_path_map_name          = "url-path-service-mapping"
  }

 
}