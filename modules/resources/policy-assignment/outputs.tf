output "policy_assignment_id" {
  description = "The ID of the policy assignment"
  value       = azurerm_policy_assignment.this.id
}

output "policy_assignment_name" {
  description = "The name of the policy assignment"
  value       = azurerm_policy_assignment.this.name
}

output "policy_assignment_identity" {
  description = "The identity of the policy assignment"
  value       = azurerm_policy_assignment.this.identity
}
