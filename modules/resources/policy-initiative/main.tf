resource "azurerm_policy_set_definition" "policy_set_definition" {
  name                = var.name
  policy_type         = var.policy_type
  display_name        = var.display_name
  description         = var.description
  management_group_id = var.management_group_id

  metadata   = var.metadata
  parameters = var.parameters

  dynamic "policy_definition_reference" {
    for_each = var.policy_definition_reference
    content {
      policy_definition_id = policy_definition_reference.value.policy_definition_id
      parameter_values     = try(policy_definition_reference.value.parameter_values, null)
      reference_id         = try(policy_definition_reference.value.reference_id, null)
      policy_group_names   = try(policy_definition_reference.value.policy_group_names, null)
    }
  }
}

