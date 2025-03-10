output "deployment_name" {
  description = "The name of the Azure Cognitive Services deployment of the OpenAI model."
  value       = azurerm_cognitive_deployment.this.name
}

output "model_name" {
  description = "The name of the AI model (deployment name)"
  value       = var.model_name
}

output "model_version" {
  description = "The version of the AI model"
  value       = var.model_version
}

# The primary key from the Cognitive Services account
output "api_key" {
  description = "The API key for accessing the AI model"
  value       = azurerm_cognitive_account.this.primary_access_key
  sensitive   = true
}

# Construct a model endpoint URL referencing the deployment name
output "endpoint_url" {
  description = "The endpoint URL for the AI model."
  value       = azurerm_cognitive_account.this.endpoint
}
