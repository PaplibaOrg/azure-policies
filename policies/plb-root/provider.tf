terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-state-eus-prod-001"
    storage_account_name = "sttfstateeusprod001"
    container_name       = "tfstate"
    key                  = "policies-prod.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.5"
    }
  }
}

provider "azurerm" {
  features {}
}
