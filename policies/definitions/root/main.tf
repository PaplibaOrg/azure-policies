terraform {
  backend "azurerm" {
    # Backend configuration will be provided via backend config file or command line
    # Example: terraform init -backend-config="resource_group_name=rg-tf-state-eus-dev-001" ...
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

variable "management_group_id" {
  description = "The management group ID where policy definitions will be deployed (e.g., dev-plb-root, test-plb-root, plb-root)"
  type        = string
}

locals {
  # Find all JSON files in the root folder - each file is a policy definition
  json_files = fileset("${path.module}", "*.json")

  # Construct full management group ID
  management_group_id = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"

  # Parse each JSON file as a policy definition
  raw_policy_definitions = {
    for file in local.json_files :
    replace(basename(file), ".json", "") => jsondecode(file("${path.module}/${file}"))
  }

  # Parse policy definitions - support multiple formats:
  # 1. Direct Azure format (displayName, policyType, etc. at root level)
  # 2. Wrapped in properties object
  # 3. Simplified format (backward compatibility)
  parsed_policy_definitions = {
    for key, value in local.raw_policy_definitions : key => {
      name                = key
      policy_type         = can(value.policyType) ? value.policyType : (can(value.properties.policyType) ? value.properties.policyType : try(value.policy_type, "Custom"))
      mode                = can(value.mode) ? value.mode : (can(value.properties.mode) ? value.properties.mode : try(value.mode, "All"))
      display_name        = can(value.displayName) ? value.displayName : (can(value.properties.displayName) ? value.properties.displayName : value.display_name)
      description         = can(value.description) ? value.description : (can(value.properties.description) ? try(value.properties.description, "") : try(value.description, ""))
      management_group_id = try(value.management_group_id, local.management_group_id)
      metadata            = try(jsonencode(value.metadata), try(jsonencode(value.properties.metadata), try(value.metadata, "{}")))
      parameters          = try(jsonencode(value.parameters), try(jsonencode(value.properties.parameters), try(value.parameters, "{}")))
      policy_rule         = can(value.policyRule) ? jsonencode(value.policyRule) : (can(value.properties.policyRule) ? jsonencode(value.properties.policyRule) : value.policy_rule)
    }
  }
}

module "policy_definitions" {
  source = "../../../modules/resources/policy-definition"
  for_each = local.parsed_policy_definitions
  name                = each.value.name
  policy_type         = each.value.policy_type
  mode                = each.value.mode
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = each.value.management_group_id
  metadata            = each.value.metadata
  parameters          = each.value.parameters
  policy_rule         = each.value.policy_rule
}

