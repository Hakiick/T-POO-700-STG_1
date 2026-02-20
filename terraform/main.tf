locals {
  resource_prefix = "${var.project_name}-${var.env}"
  tags = {
    project     = var.project_name
    environment = var.env
    managed_by  = "terraform"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_prefix}"
  location = var.location
  tags     = local.tags
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "cr${replace(local.resource_prefix, "-", "")}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku
  admin_enabled       = true
  tags                = local.tags
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "asp-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = local.tags
}

# App Service (Linux Web App — Docker container)
resource "azurerm_linux_web_app" "timemanager" {
  name                = "app-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = local.tags

  site_config {
    always_on                         = var.sku_name != "F1"
    http2_enabled                     = true
    minimum_tls_version               = "1.2"
    ftps_state                        = "Disabled"
    health_check_path                 = "/api/health"
    health_check_eviction_time_in_min = 10

    application_stack {
      docker_registry_url      = "https://${azurerm_container_registry.main.login_server}"
      docker_image_name        = "${var.project_name}:${var.docker_image_tag}"
      docker_registry_username = azurerm_container_registry.main.admin_username
      docker_registry_password = azurerm_container_registry.main.admin_password
    }
  }

  app_settings = {
    PORT                            = "4000"
    PHX_SERVER                      = "true"
    PHX_HOST                        = "app-${local.resource_prefix}.azurewebsites.net"
    SECRET_KEY_BASE                 = var.secret_key_base
    DATABASE_URL                    = "ecto://${var.postgres_admin_login}:${var.postgres_admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}/${azurerm_postgresql_flexible_server_database.main.name}?ssl=true"
    WEBSITES_PORT                   = "80"
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.main.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.main.admin_password
  }
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                         = "psql-${local.resource_prefix}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = var.postgres_version
  administrator_login          = var.postgres_admin_login
  administrator_password       = var.postgres_admin_password
  sku_name                     = var.postgres_sku_name
  zone                         = "1"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  tags                         = local.tags

  storage_mb = 32768
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = "timemanager"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "utf8"
  collation = "en_US.utf8"
}

# Firewall rule — allow Azure services
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Firewall rule — allow deploy VM
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_deploy_vm" {
  name             = "AllowDeployVM"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "109.8.247.50"
  end_ip_address   = "109.8.247.50"
}
