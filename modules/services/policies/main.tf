locals {
  # Convert tags object to map(string) for Azure
  tags_map = merge(
    {
      environment = var.environment
      owner       = var.tags.owner
      application = var.tags.application
      managedBy   = "terraform"
    },
    var.additional_tags
  )
}

# Policy Definitions
module "policy_definitions" {
  source = "../../resources/policy-definition"

  for_each = var.policy_definitions

  name                = each.value.name
  policy_type         = lookup(each.value, "policy_type", "Custom")
  mode                = lookup(each.value, "mode", "All")
  display_name        = each.value.display_name
  description         = lookup(each.value, "description", "")
  management_group_id = lookup(each.value, "management_group_id", null)
  metadata            = lookup(each.value, "metadata", "{}")
  parameters          = lookup(each.value, "parameters", "{}")
  policy_rule         = each.value.policy_rule
  tags                = local.tags_map
}

# Policy Initiatives
module "policy_initiatives" {
  source = "../../resources/policy-initiative"

  for_each = var.policy_initiatives

  name                = each.value.name
  policy_type         = lookup(each.value, "policy_type", "Custom")
  display_name        = each.value.display_name
  description         = lookup(each.value, "description", "")
  management_group_id = lookup(each.value, "management_group_id", null)
  metadata            = lookup(each.value, "metadata", "{}")
  parameters          = lookup(each.value, "parameters", "{}")
  policy_definition_reference = each.value.policy_definition_reference
  tags                = local.tags_map

  depends_on = [module.policy_definitions]
}

# Policy Assignments
module "policy_assignments" {
  source = "../../resources/policy-assignment"

  for_each = var.policy_assignments

  name                 = each.value.name
  display_name          = each.value.display_name
  description           = lookup(each.value, "description", "")
  scope                 = each.value.scope
  policy_definition_id  = each.value.policy_definition_id
  location              = lookup(each.value, "location", null)
  identity_type         = lookup(each.value, "identity_type", "None")
  not_scopes           = lookup(each.value, "not_scopes", [])
  parameters           = lookup(each.value, "parameters", "{}")
  metadata             = lookup(each.value, "metadata", "{}")
  enforcement_mode     = lookup(each.value, "enforcement_mode", "Default")
  tags                 = local.tags_map

  depends_on = [
    module.policy_definitions,
    module.policy_initiatives
  ]
}
