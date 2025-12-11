terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-state-eus-dev-001"
    storage_account_name = "sttfstateeusdev001"
    container_name       = "tfstate"
    key                  = "policy-assignments-dev.tfstate"
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

locals {
  # Recursively find all JSON files at any depth using ** pattern
  json_files = fileset("${path.module}", "**/*.json")

  # Decode JSON once per file and filter out files that have policy_assignments
  raw_json_files = {
    for file in local.json_files :
    file => jsondecode(file("${path.module}/${file}"))
    if can(jsondecode(file("${path.module}/${file}")).environment) &&
    can(jsondecode(file("${path.module}/${file}")).policy_assignments)
  }

  # Final map used for for_each - use a unique key based on file path
  json_object_map = {
    for key, json_data in local.raw_json_files :
    replace(key, ".json", "") => json_data
  }

  # Convert tags object to map(string) for Azure
  tags_map = merge(
    {
      environment = try(local.json_object_map[keys(local.json_object_map)[0]].environment, "")
      owner       = try(lookup(local.json_object_map[keys(local.json_object_map)[0]], "tags", {}).owner, "")
      application = try(lookup(local.json_object_map[keys(local.json_object_map)[0]], "tags", {}).application, "")
      managedBy   = "terraform"
    },
    try(lookup(local.json_object_map[keys(local.json_object_map)[0]], "additional_tags", {}), {})
  )
}

module "policy_assignments" {
  source = "../../../modules/resources/policy-assignment"

  for_each = merge([
    for file_key, file_data in local.json_object_map :
    {
      for key, value in lookup(file_data, "policy_assignments", {}) :
      "${file_key}-${key}" => value
    }
  ]...)

  name                 = each.value.name
  display_name         = each.value.display_name
  description          = lookup(each.value, "description", "")
  scope                = each.value.scope
  policy_definition_id = each.value.policy_definition_id
  location             = lookup(each.value, "location", null)
  identity_type        = lookup(each.value, "identity_type", "None")
  not_scopes          = lookup(each.value, "not_scopes", [])
  parameters           = lookup(each.value, "parameters", "{}")
  metadata             = lookup(each.value, "metadata", "{}")
  enforcement_mode     = lookup(each.value, "enforcement_mode", "Default")
  tags                 = local.tags_map
}
