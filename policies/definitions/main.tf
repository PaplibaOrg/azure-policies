# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~>4.0"
#     }
#   }
#
#   backend "azurerm" {
#     resource_group_name  = "rg-tf-state-eus-test-001"
#     storage_account_name = "sttfstateeustest001"
#     container_name       = "tfstate"
#     key                  = "policy-definitions-test.tfstate"
#   }
# }
#
# provider "azurerm" {
#   features {}
#   tenant_id = "99e184df-412c-45ed-b033-63f70449fe62"
# }

# variable "env" {
#   description = "Environment"
#   type        = string
#
#   validation {
#     condition     = contains(["dev", "test", "prod"], var.variableName)
#     error_message = "env should be dev, test or prod."
#   }
# }

# locals {
#   json_object = jsondecode(file("${path.module}/policy.json"))
#   environment = var.env == "prod" ? "" : var.env == "test" ? "test-" : "dev-"
# }
#
# resource "azurerm_policy_definition" "policy" {
#   name                = local.json_object.name
#   policy_type         = local.json_object.policy_type
#   mode                = local.json_object.mode
#   display_name        = local.json_object.displayName
#   description         = local.json_object.description
#   management_group_id = "/providers/Microsoft.Management/managementGroups/${environment}plb-root"
#   metadata            = jsonencode(local.json_object.metadata)
#   policy_rule         = jsonencode(local.json_object.policyRule)
#   parameters          = jsonencode(local.json_object.parameter)
# }
#
# output "policy_definition_id" {
#   value = azurerm_policy_definition.policy.id
# }
#
# output "policy_definition_name" {
#   value = azurerm_policy_definition.policy.role_definition_ids
# }
#
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "random" {
}

resource "random_id" "policy_suffix" {
  byte_length = 4
}

output "random_name" {
  value = random_id.policy_suffix
}
