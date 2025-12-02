variable "name" {
  description = "The name of the policy assignment"
  type        = string
}

variable "display_name" {
  description = "The display name of the policy assignment"
  type        = string
}

variable "description" {
  description = "The description of the policy assignment"
  type        = string
  default     = ""
}

variable "scope" {
  description = "The scope at which the policy assignment is created"
  type        = string
}

variable "policy_definition_id" {
  description = "The ID of the policy definition or policy set definition to assign"
  type        = string
}

variable "location" {
  description = "The location where the policy assignment should be created (required for policies with location-based effects)"
  type        = string
  default     = null
}

variable "identity_type" {
  description = "The type of managed identity to assign. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned"
  type        = string
  default     = "None"
}

variable "not_scopes" {
  description = "A list of resource IDs that should be excluded from the policy assignment"
  type        = list(string)
  default     = []
}

variable "parameters" {
  description = "Parameters for the policy assignment"
  type        = string
  default     = "{}"
}

variable "metadata" {
  description = "The metadata for the policy assignment"
  type        = string
  default     = "{}"
}

variable "enforcement_mode" {
  description = "Whether the policy assignment is enforced. Possible values are Default, DoNotEnforce"
  type        = string
  default     = "Default"
}

variable "tags" {
  description = "Tags to apply to the policy assignment"
  type        = map(string)
  default     = {}
}
