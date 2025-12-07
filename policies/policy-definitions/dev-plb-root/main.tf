terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-state-eus-dev-001"
    storage_account_name = "sttfstateeusdev001"
    container_name       = "tfstate"
    key                  = "policy-definitions-dev.tfstate"
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

variable "environment" {
  description = "Environment name (not used for policy definitions, but required by module)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Base tags object (not used for policy definitions, but required by module)"
  type = object({
    owner       = string
    application = string
  })
  default = {
    owner       = ""
    application = ""
  }
}

variable "additional_tags" {
  description = "Additional tags (not used for policy definitions, but required by module)"
  type        = map(string)
  default     = {}
}

locals {
  # Recursively find all JSON files - each file is a policy definition
  json_files = fileset("${path.module}", "*.json")

  # Management group ID is the folder name
  management_group_id = basename(path.module)

  # Parse each JSON file as a policy definition
  raw_policy_definitions = {
    for file in local.json_files :
    replace(basename(file), ".json", "") => jsondecode(file("${path.module}/${file}"))
  }

  # Add management_group_id to each policy definition
  policy_definitions = {
    for key, value in local.raw_policy_definitions :
    key => merge(
      value,
      {
        management_group_id = local.management_group_id
      }
    )
  }
}

module "policies" {
  source = "../../../modules/services/policies"
  environment     = var.environment
  tags            = var.tags
  additional_tags = var.additional_tags
  policy_definitions  = local.policy_definitions
  policy_initiatives  = {}
  policy_assignments  = {}
}
