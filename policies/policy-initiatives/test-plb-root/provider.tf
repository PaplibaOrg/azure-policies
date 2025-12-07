terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-state-eus-test-001"
    storage_account_name = "sttfstateeustest001"
    container_name       = "tfstate"
    key                  = "policy-initiatives-test.tfstate"
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
