variable "env" {
  type        = string
  default     = "dev"
  description = "Deployment environment (dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of: dev, staging, prod."
  }
}

variable "location" {
  type        = string
  default     = "swedencentral"
  description = "Azure region for all resources"
  validation {
    condition     = contains(["uksouth", "swedencentral", "polandcentral", "switzerlandnorth", "germanywestcentral"], var.location)
    error_message = "location must be one of: uksouth, swedencentral, polandcentral, switzerlandnorth, germanywestcentral."
  }
}

variable "project_name" {
  type        = string
  default     = "timemanager"
  description = "Project name used in resource naming"
}

variable "subscription_id" {
  type        = string
  sensitive   = true
  description = "Azure subscription ID"
}

variable "sku_name" {
  type        = string
  default     = "B1"
  description = "SKU name for the App Service Plan"
}

variable "postgres_admin_login" {
  type        = string
  default     = "pgadmin"
  description = "Administrator login for PostgreSQL Flexible Server"
  validation {
    condition     = !contains(["admin", "postgres"], var.postgres_admin_login)
    error_message = "postgres_admin_login must not be 'admin' or 'postgres'."
  }
}

variable "postgres_admin_password" {
  type        = string
  sensitive   = true
  description = "Administrator password for PostgreSQL Flexible Server"
  validation {
    condition     = length(var.postgres_admin_password) >= 8
    error_message = "postgres_admin_password must be at least 8 characters long."
  }
}

variable "postgres_sku_name" {
  type        = string
  default     = "B_Standard_B1ms"
  description = "SKU name for the PostgreSQL Flexible Server"
}

variable "postgres_version" {
  type        = string
  default     = "16"
  description = "PostgreSQL version"
}

variable "acr_sku" {
  type        = string
  default     = "Basic"
  description = "SKU for the Azure Container Registry"
}

variable "docker_image_tag" {
  type        = string
  default     = "latest"
  description = "Docker image tag to deploy on App Service"
}

variable "secret_key_base" {
  type        = string
  sensitive   = true
  description = "Phoenix secret key base for sessions/tokens (generate with: mix phx.gen.secret)"
}
