terraform {
  required_version = "~> 1.8.0"

  backend "azurerm" {
    resource_group_name  = "Manual"
    storage_account_name = "iscahomdtfstate"
    container_name       = "single"
    key                  = "aks"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.99.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}
