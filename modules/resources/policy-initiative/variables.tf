variable "name" {
  description = "The name of the policy set definition (initiative)"
  type        = string
}

variable "policy_type" {
  description = "The policy type. Possible values are BuiltIn, Custom, NotSpecified, Static"
  type        = string
  default     = "Custom"
}

variable "display_name" {
  description = "The display name of the policy set definition"
  type        = string
}

variable "description" {
  description = "The description of the policy set definition"
  type        = string
  default     = ""
}

variable "management_group_id" {
  description = "The management group ID where the policy set definition should be created. If not provided, created at subscription level."
  type        = string
  default     = null
}

variable "metadata" {
  description = "The metadata for the policy set definition"
  type        = string
  default     = "{}"
}

variable "parameters" {
  description = "Parameters for the policy set definition"
  type        = string
  default     = "{}"
}

variable "policy_definition_reference" {
  description = "One or more policy_definition_reference blocks"
  type = list(object({
    policy_definition_id = string
    parameter_values     = optional(string)
    reference_id         = optional(string)
    policy_group_names   = optional(list(string))
  }))
}

