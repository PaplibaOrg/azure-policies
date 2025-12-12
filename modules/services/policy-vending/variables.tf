variable "management_group_id" {
  description = "The default management group ID where policies will be deployed (e.g., /providers/Microsoft.Management/managementGroups/dev-plb-root)"
  type        = string
  default     = null
}

variable "policy_definitions" {
  description = "Map of policy definitions to create"
  type = map(object({
    name                = string
    policy_type         = optional(string, "Custom")
    mode                = optional(string, "All")
    display_name        = string
    description         = optional(string, "")
    management_group_id = optional(string)
    metadata            = optional(string, "{}")
    parameters          = optional(string, "{}")
    policy_rule         = string
  }))
  default = {}
}

variable "policy_initiatives" {
  description = "Map of policy initiatives (policy set definitions) to create"
  type = map(object({
    name                = string
    policy_type         = optional(string, "Custom")
    display_name        = string
    description         = optional(string, "")
    management_group_id = optional(string)
    metadata            = optional(string, "{}")
    parameters          = optional(string, "{}")
    policy_definition_reference = list(object({
      policy_definition_id = string
      parameter_values     = optional(string)
      reference_id         = optional(string)
      policy_group_names   = optional(list(string))
    }))
  }))
  default = {}
}

variable "policy_assignments" {
  description = "Map of policy assignments to create"
  type = map(object({
    name                 = string
    display_name         = string
    description          = optional(string, "")
    scope                = string
    policy_definition_id = string
    identity_type        = optional(string, "None")
    not_scopes          = optional(list(string), [])
    parameters           = optional(string, "{}")
    metadata             = optional(string, "{}")
    enforcement_mode     = optional(string, "Default")
    tags                 = optional(map(string), {})
  }))
  default = {}
}

