locals {
  # Recursively find all JSON files - each file is a policy definition
  json_files = fileset("${path.module}", "*.json")

  # Management group ID is the folder name
  management_group_id = basename(path.module)

  # Parse each JSON file as a policy definition
  raw_policy_definitions = {
    for file in local.json_files :
    replace(basename(file), ".json", "") => jsondecode(file("${path.module}/${file}"))
  }

  # Add management_group_id to each policy definition
  policy_definitions = {
    for key, value in local.raw_policy_definitions :
    key => merge(
      value,
      {
        management_group_id = local.management_group_id
      }
    )
  }
}

module "policies" {
  source = "../../../modules/services/policies"
  environment     = var.environment
  tags            = var.tags
  additional_tags = var.additional_tags
  policy_definitions  = local.policy_definitions
  policy_initiatives  = {}
  policy_assignments  = {}
}
