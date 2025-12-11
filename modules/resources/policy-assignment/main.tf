resource "azurerm_policy_assignment" "this" {
  name                 = var.name
  display_name         = var.display_name
  description          = var.description
  scope                = var.scope
  policy_definition_id = var.policy_definition_id

  dynamic "identity" {
    for_each = var.identity_type != "None" ? [1] : []
    content {
      type = var.identity_type
    }
  }

  not_scopes       = var.not_scopes
  parameters       = var.parameters
  metadata         = var.metadata
  enforcement_mode = var.enforcement_mode

  tags = var.tags
}

