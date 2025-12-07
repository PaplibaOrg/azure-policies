locals {
  # Recursively find all JSON files at any depth using ** pattern
  json_files = fileset("${path.module}", "**/*.json")

  # Decode JSON once per file and filter out files that don't have required fields
  raw_json_files = {
    for file in local.json_files :
    file => jsondecode(file("${path.module}/${file}"))
    if can(jsondecode(file("${path.module}/${file}")).environment)
  }

  # Final map used for for_each - use a unique key based on file path
  json_object_map = {
    for key, json_data in local.raw_json_files :
    replace(key, ".json", "") => json_data
  }
}

module "policies" {
  source = "../../modules/services/policies"

  for_each = local.json_object_map

  environment     = each.value.environment
  tags            = lookup(each.value, "tags", {})
  additional_tags = lookup(each.value, "additional_tags", {})

  policy_definitions  = lookup(each.value, "policy_definitions", {})
  policy_initiatives  = lookup(each.value, "policy_initiatives", {})
  policy_assignments  = lookup(each.value, "policy_assignments", {})
}
