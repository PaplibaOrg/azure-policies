locals {
  # Read all JSON files in subdirectories
  json_object_map = {
    for file in fileset(path.module, "*/*.json") :
    "${split("/", file)[0]}/${jsondecode(file(file)).environment}/${jsondecode(file(file)).version}" => jsondecode(file(file))
  }
}

module "policies" {
  source = "../modules/services/policies"

  for_each = local.json_object_map

  environment     = each.value.environment
  tags            = each.value.tags
  additional_tags = lookup(each.value, "additional_tags", {})

  policy_definitions  = lookup(each.value, "policy_definitions", {})
  policy_initiatives  = lookup(each.value, "policy_initiatives", {})
  policy_assignments  = lookup(each.value, "policy_assignments", {})
}
