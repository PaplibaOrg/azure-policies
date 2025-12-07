output "policy_definition_ids" {
  description = "Map of policy definition IDs"
  value = {
    for key, def in module.policy_definitions :
    key => def.policy_definition_id
  }
}

output "policy_initiative_ids" {
  description = "Map of policy initiative IDs"
  value = {
    for key, initiative in module.policy_initiatives :
    key => initiative.policy_set_definition_id
  }
}

output "policy_assignment_ids" {
  description = "Map of policy assignment IDs"
  value = {
    for key, assignment in module.policy_assignments :
    key => assignment.policy_assignment_id
  }
}

