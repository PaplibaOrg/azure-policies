terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-state-eus-dev-001"
    storage_account_name = "sttfstateeusdev001"
    container_name       = "tfstate"
    key                  = "policy-initiatives-dev.tfstate"
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
