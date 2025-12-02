variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
}

variable "tags" {
  description = "Base tags object"
  type = object({
    owner       = string
    application = string
  })
}

variable "additional_tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}

variable "policy_definitions" {
  description = "Map of policy definitions to create"
  type = map(object({
    name                = string
    policy_type         = optional(string)
    mode                = optional(string)
    display_name        = string
    description         = optional(string)
    management_group_id = optional(string)
    metadata            = optional(string)
    parameters          = optional(string)
    policy_rule         = string
  }))
  default = {}
}

variable "policy_initiatives" {
  description = "Map of policy initiatives (policy sets) to create"
  type = map(object({
    name                      = string
    policy_type               = optional(string)
    display_name              = string
    description               = optional(string)
    management_group_id       = optional(string)
    metadata                  = optional(string)
    parameters                = optional(string)
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
    name                = string
    display_name        = string
    description         = optional(string)
    scope               = string
    policy_definition_id = string
    location            = optional(string)
    identity_type       = optional(string)
    not_scopes          = optional(list(string))
    parameters          = optional(string)
    metadata            = optional(string)
    enforcement_mode    = optional(string)
  }))
  default = {}
}
