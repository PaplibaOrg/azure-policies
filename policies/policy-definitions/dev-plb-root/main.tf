locals {
  # Recursively find all JSON files - each file is a policy definition
  json_files = fileset("${path.module}", "*.json")

  # Extract environment from folder name (e.g., dev-plb-root -> dev)
  environment = split("-", basename(path.module))[0]

  # Default tags
  default_tags = {
    owner       = "platform-team"
    application = "policy-management"
  }

  default_additional_tags = {
    managedBy = "terraform"
  }

  # Parse each JSON file as a policy definition
  policy_definitions = {
    for file in local.json_files :
    replace(basename(file), ".json", "") => jsondecode(file("${path.module}/${file}"))
  }
}

module "policies" {
  source = "../../../modules/services/policies"

  environment     = local.environment
  tags            = local.default_tags
  additional_tags = local.default_additional_tags

  policy_definitions  = local.policy_definitions
  policy_initiatives  = {}
  policy_assignments  = {}
}
