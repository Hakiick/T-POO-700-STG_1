output "app_url" {
  description = "Public HTTPS URL of the TimeManager App Service"
  value       = "https://${azurerm_linux_web_app.timemanager.default_hostname}"
}

output "acr_login_server" {
  description = "Login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  description = "Admin username for the Azure Container Registry"
  value       = azurerm_container_registry.main.admin_username
}

output "acr_admin_password" {
  description = "Admin password for the Azure Container Registry"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

output "postgres_fqdn" {
  description = "Fully qualified domain name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgres_database" {
  description = "Name of the PostgreSQL database"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "resource_group_name" {
  description = "Name of the Azure Resource Group"
  value       = azurerm_resource_group.main.name
}
