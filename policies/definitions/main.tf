terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tf-state-eus-test-001"
    storage_account_name = "sttfstateeustest001"
    container_name       = "tfstate"
    key                  = "policy-definitions-test.tfstate"
  }
}

provider "azurerm" {
  features {}
  tenant_id = "99e184df-412c-45ed-b033-63f70449fe62"
}

variable "env" {
  description = "Environment"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.variableName)
    error_message = "env should be dev, test or prod."
  }
}

locals {
  json_object = jsondecode(file("${path.module}/policy.json"))
  environment = var.env == "prod" ? "" : var.env == "test" ? "test-" : "dev-"
}

resource "azurerm_policy_definition" "policy" {
  name                = json_object.name
  policy_type         = json_object.policy_type
  mode                = json_object.mode
  display_name        = json_object.displayName
  description         = json_object.description
  management_group_id = "/providers/Microsoft.Management/managementGroups/${environment}plb-root"
  metadata            = jsonencode(json_object.metadata)
  policy_rule         = jsonencode(json_object.policyRule)
  parameters          = jsonencode(json_object.parameter)
}

output "policy_definition_id" {
  value = azurerm_policy_definition.policy.id
}

output "policy_definition_name" {
  value = azurerm_policy_definition.policy.role_definition_ids
}

