output "policy_definition_id" {
  description = "The ID of the policy definition"
  value       = azurerm_policy_definition.this.id
}

output "policy_definition_name" {
  description = "The name of the policy definition"
  value       = azurerm_policy_definition.this.name
}
