{
  "environment": "dev",
  "version": "1.0.0",
  "tags": {
    "owner": "sunny.bharne",
    "application": "vending"
  },
  "additional_tags": {
    "costCenter": "platform",
    "project": "policy-management"
  },
  "policy_assignments": {
    "assign-require-tag-environment": {
      "name": "assign-require-tag-environment",
      "display_name": "Assign Require Environment Tag Policy",
      "scope": "${platform_mg_id}",
      "policy_definition_id": "${full_mg_id}/providers/Microsoft.Authorization/policyDefinitions/require-tag-environment"
    }
  }
}
