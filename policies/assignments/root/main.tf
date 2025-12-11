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
  description = "The management group ID where policy assignments will be deployed (e.g., dev-plb-root, test-plb-root, plb-root)"
  type        = string
}

locals {
  # Recursively find all JSON files at any depth using ** pattern
  json_files = fileset("${path.module}", "**/*.json")

  # Construct full management group ID
  management_group_id = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"

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
      "${file_key}-${key}" => merge(
        value,
        {
          # Replace hardcoded management group references with dynamic values
          # Replace dev-plb-root, test-plb-root, plb-root with the actual management_group_id
          # Replace dev-plb-platform, test-plb-platform, plb-platform with platform variant
          scope = replace(
            replace(
              replace(
                replace(
                  replace(
                    replace(value.scope, "dev-plb-root", var.management_group_id),
                    "test-plb-root", var.management_group_id
                  ),
                  "plb-root", var.management_group_id
                ),
                "dev-plb-platform", replace(var.management_group_id, "-root", "-platform")
              ),
              "test-plb-platform", replace(var.management_group_id, "-root", "-platform")
            ),
            "plb-platform", replace(var.management_group_id, "-root", "-platform")
          )
          policy_definition_id = replace(
            replace(
              replace(value.policy_definition_id, "dev-plb-root", var.management_group_id),
              "test-plb-root", var.management_group_id
            ),
            "plb-root", var.management_group_id
          )
        }
      )
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
