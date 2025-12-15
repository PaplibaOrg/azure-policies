locals {
  files      = fileset(path.module, "**/*.json")
  files_maps = { for x in local.files : "${basename(dirname("${path.cwd}/${x}"))}/${jsondecode("${file(x)}").name}-${jsondecode("${file(x)}").metadata.version}" => jsondecode(file(x)) }
}

# resource "azurerm_management_group_policy_set_definition" "initiative" {
#   for_each                    = local.files_maps
#   name                        = each.value.name
#   display_name                = each.value.displayName
#   policy_type                 = each.value.policyType
#   metadata                    = jsonencode(each.value.metadata)
#   parameters                  = jsonencode(each.value.parameters)
#   policy_definition_group     = jsonencode(each.value.policyDefinitionGroup)
#   policy_definition_reference = jsonencode(each.value.policyDefinitionReference)
#   management_group_id         = "/providers/Microsoft.Management/managementGroups/${split("/", each.key)[0]}"
# }

# resource "azurerm_policy_definition" "definition" {
#   for_each            = local.files_maps
#   name                = each.value.name
#   policy_type         = each.value.policyType
#   mode                = each.value.mode
#   display_name        = each.value.displayName
#   description         = each.value.description
#   metadata            = jsonencode(each.value.metadata)
#   parameters          = jsonencode(each.value.parameters)
#   policy_rule         = jsonencode(each.value.policyRule)
#   management_group_id = "/providers/Microsoft.Management/managementGroups/${split("/", each.key)[0]}"
# }

output "print" {
  value = local.files_maps
}
