# Policy Definitions Outputs
output "policy_definition_ids" {
  description = "Map of policy definition IDs"
  value = {
    for key, module in module.policy_definitions :
    key => module.policy_definition_id
  }
}

output "policy_definition_names" {
  description = "Map of policy definition names"
  value = {
    for key, module in module.policy_definitions :
    key => module.policy_definition_name
  }
}

# Policy Initiatives Outputs
output "policy_initiative_ids" {
  description = "Map of policy initiative (policy set definition) IDs"
  value = {
    for key, module in module.policy_initiatives :
    key => module.policy_set_definition_id
  }
}

output "policy_initiative_names" {
  description = "Map of policy initiative (policy set definition) names"
  value = {
    for key, module in module.policy_initiatives :
    key => module.policy_set_definition_name
  }
}

# Policy Assignments Outputs
output "policy_assignment_ids" {
  description = "Map of policy assignment IDs"
  value = {
    for key, module in module.policy_assignments :
    key => module.policy_assignment_id
  }
}

output "policy_assignment_names" {
  description = "Map of policy assignment names"
  value = {
    for key, module in module.policy_assignments :
    key => module.policy_assignment_name
  }
}

output "policy_assignment_identities" {
  description = "Map of policy assignment identities"
  value = {
    for key, module in module.policy_assignments :
    key => module.policy_assignment_identity
  }
}

