resource "random_password" "csb_app_password" {
  length      = 64
  special     = false
  min_special = 0
  min_upper   = 5
  min_numeric = 5
  min_lower   = 5
}

output "password" {
  sensitive = true
  # check the statefile for the result
  value = random_password.csb_app_password.result
}
