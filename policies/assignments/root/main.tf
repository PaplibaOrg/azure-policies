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
  # Construct full management group ID and platform variant
  management_group_id = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  platform_mg_id      = "/providers/Microsoft.Management/managementGroups/${replace(var.management_group_id, "-root", "-platform")}"

  # Recursively find all JSON template files at any depth using ** pattern
  json_template_files = fileset("${path.module}", "**/*.json.tpl")

  # Process template files with variables
  processed_json_files = {
    for file in local.json_template_files :
    replace(file, ".tpl", "") => jsondecode(templatefile("${path.module}/${file}", {
      management_group_id = var.management_group_id
      full_mg_id          = local.management_group_id
      platform_mg_id      = local.platform_mg_id
    }))
  }

  # Also find regular JSON files (non-template) for backward compatibility
  json_files = fileset("${path.module}", "**/*.json")

  # Decode JSON once per file and filter out files that have policy_assignments
  raw_json_files = merge(
    local.processed_json_files,
    {
      for file in local.json_files :
      file => jsondecode(file("${path.module}/${file}"))
      if !endswith(file, ".tpl") && can(jsondecode(file("${path.module}/${file}")).environment) &&
      can(jsondecode(file("${path.module}/${file}")).policy_assignments)
    }
  )

  # Final map used for for_each - use a unique key based on file path
  json_object_map = {
    for key, json_data in local.raw_json_files :
    replace(key, ".json", "") => json_data
    if can(json_data.environment) && can(json_data.policy_assignments)
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
          # Replace in full Azure resource IDs (e.g., "/providers/Microsoft.Management/managementGroups/dev-plb-root")
          scope = replace(
            replace(
              replace(
                replace(
                  replace(
                    replace(value.scope, "/managementGroups/dev-plb-root", "/managementGroups/${var.management_group_id}"),
                    "/managementGroups/test-plb-root", "/managementGroups/${var.management_group_id}"
                  ),
                  "/managementGroups/plb-root", "/managementGroups/${var.management_group_id}"
                ),
                "/managementGroups/dev-plb-platform", "/managementGroups/${replace(var.management_group_id, "-root", "-platform")}"
              ),
              "/managementGroups/test-plb-platform", "/managementGroups/${replace(var.management_group_id, "-root", "-platform")}"
            ),
            "/managementGroups/plb-platform", "/managementGroups/${replace(var.management_group_id, "-root", "-platform")}"
          )
          policy_definition_id = replace(
            replace(
              replace(value.policy_definition_id, "/managementGroups/dev-plb-root", "/managementGroups/${var.management_group_id}"),
              "/managementGroups/test-plb-root", "/managementGroups/${var.management_group_id}"
            ),
            "/managementGroups/plb-root", "/managementGroups/${var.management_group_id}"
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
