provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "ghActions-rg"
  location = "East US"
}

resource "azurerm_app_service_plan" "plan" {
  name                = "myapp-demo-plan"
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
  name                = "myapp-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "DOCKER|wuonam/gh-test:latest"
    always_on        = true
  }

  app_settings = {
    WEBSITES_PORT = "3000"
  }

  https_only = true
}

output "app_url" {
  value = "https://${azurerm_app_service.app.default_site_hostname}"
}
