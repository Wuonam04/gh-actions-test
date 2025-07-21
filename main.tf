provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  default = "ghActions-rg"
}

variable "location" {
  default = "East US"
}

variable "app_name" {
  default = "simple_app"
}

variable "docker_image" {
  description = "Docker image"
}

variable "container_port" {
  default = "3000"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${var.app_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app" {
  name                = var.app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "DOCKER|${var.docker_image}"
    always_on        = true
  }

  app_settings = {
    WEBSITES_PORT = var.container_port
  }

  https_only = true
}

output "app_url" {
  value = "https://${azurerm_app_service.app.default_site_hostname}"
}
