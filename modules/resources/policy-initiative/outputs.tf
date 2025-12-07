output "policy_set_definition_id" {
  description = "The ID of the policy set definition"
  value       = azurerm_policy_set_definition.this.id
}

output "policy_set_definition_name" {
  description = "The name of the policy set definition"
  value       = azurerm_policy_set_definition.this.name
}

