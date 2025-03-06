# Based on this example: https://github.com/Azure/terraform-azurerm-avm-res-cognitiveservices-account/tree/main/examples/default

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "rg-cloudgov-azureai-${var.instance_id}"
}

resource "azurerm_cognitive_account" "this" {
  kind                = "OpenAI"
  location            = azurerm_resource_group.this.location
  name                = "cog-cloudgov-azureai-${var.instance_id}"
  sku_name            = "S0"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_cognitive_deployment" "this" {
  cognitive_account_id = azurerm_cognitive_account.this.id
  name                 = "cog-cloudgov-azureai-${var.instance_id}-${var.model_name}"

  model {
    name    = var.model_name
    format  = "OpenAI"
    version = var.model_version
  }
  sku {
    name = "Standard"
  }
}
