terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "< 5.0.0"
    }
    random = {
      source = "registry.terraform.io/hashicorp/random"
    }
    azapi = {
      source = "registry.terraform.io/Azure/azapi"
    }
    modtm = {
      source = "registry.terraform.io/Azure/modtm"
    }
  }
}
