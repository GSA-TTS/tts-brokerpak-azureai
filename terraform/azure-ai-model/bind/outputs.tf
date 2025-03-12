output "model_name" {
  value = var.model_name
}

output "model_version" {
  value = var.model_version
}

output "api_key" {
  sensitive = true
  value     = var.api_key
}

output "endpoint_url" {
  value = var.endpoint_url
}

output "deployment_name" {
  description = "The name of the Azure Cognitive Services deployment of the OpenAI model."
  value       = var.deployment_name
}
