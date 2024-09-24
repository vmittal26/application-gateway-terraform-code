terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
    azapi = {   
      source = "azure/azapi"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  subscription_id = "3fca4538-23fa-4853-94bd-604378fbbb2b"
  tenant_id       = "bf0c06c2-6aa7-4abe-9732-ce9b2b3c7264"
  features {
  }
}