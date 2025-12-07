resource "azurerm_policy_set_definition" "this" {
  name                = var.name
  policy_type         = var.policy_type
  display_name        = var.display_name
  description         = var.description
  management_group_id = var.management_group_id

  metadata    = var.metadata
  parameters  = var.parameters
  policy_definition_reference = var.policy_definition_reference

  tags = var.tags
}

