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

locals {
  # Recursively find all JSON files at any depth using ** pattern
  json_files = fileset("${path.module}", "**/*.json")

  # Management group ID is the folder name - extract from current working directory
  # In pipeline, we cd into this directory, so path.cwd will have the full path
  # Format: /providers/Microsoft.Management/managementGroups/{name}
  mg_name = reverse(split("/", path.cwd))[0]
  management_group_id = "/providers/Microsoft.Management/managementGroups/${local.mg_name}"

  # Decode JSON once per file and filter out files that have policy_initiatives
  raw_json_files = {
    for file in local.json_files :
    file => jsondecode(file("${path.module}/${file}"))
    if can(jsondecode(file("${path.module}/${file}")).environment) &&
    can(jsondecode(file("${path.module}/${file}")).policy_initiatives)
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

module "policy_initiatives" {
  source = "../../../modules/resources/policy-initiative"

  for_each = merge([
    for file_key, file_data in local.json_object_map :
    {
      for key, value in lookup(file_data, "policy_initiatives", {}) :
      "${file_key}-${key}" => merge(
        value,
        {
          # Convert policy definition references: if policy_definition_name is provided, construct full ID
          # Otherwise use policy_definition_id as-is
          policy_definition_reference = [
            for ref in lookup(value, "policy_definition_reference", []) :
            {
              policy_definition_id = can(ref.policy_definition_name) ? (
                "${local.management_group_id}/providers/Microsoft.Authorization/policyDefinitions/${ref.policy_definition_name}"
              ) : ref.policy_definition_id
              parameter_values   = try(ref.parameter_values, null)
              reference_id       = try(ref.reference_id, null)
              policy_group_names = try(ref.policy_group_names, null)
            }
          ]
        }
      )
    }
  ]...)

  name                = each.value.name
  policy_type         = lookup(each.value, "policy_type", "Custom")
  display_name        = each.value.display_name
  description         = lookup(each.value, "description", "")
  management_group_id = try(each.value.management_group_id, local.management_group_id)
  metadata            = lookup(each.value, "metadata", "{}")
  parameters          = lookup(each.value, "parameters", "{}")
  policy_definition_reference = each.value.policy_definition_reference
  tags                = local.tags_map
}
