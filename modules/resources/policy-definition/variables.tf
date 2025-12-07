variable "name" {
  description = "The name of the policy definition"
  type        = string
}

variable "policy_type" {
  description = "The policy type. Possible values are BuiltIn, Custom, NotSpecified, Static"
  type        = string
  default     = "Custom"
}

variable "mode" {
  description = "The policy mode. Possible values are All, Indexed, Microsoft.KeyVault.Data, Microsoft.Network.Data, Microsoft.ContainerService.Data, Microsoft.Kubernetes.Data"
  type        = string
  default     = "All"
}

variable "display_name" {
  description = "The display name of the policy definition"
  type        = string
}

variable "description" {
  description = "The description of the policy definition"
  type        = string
  default     = ""
}

variable "management_group_id" {
  description = "The management group ID where the policy definition should be created. If not provided, created at subscription level."
  type        = string
  default     = null
}

variable "metadata" {
  description = "The metadata for the policy definition"
  type        = string
  default     = "{}"
}

variable "parameters" {
  description = "Parameters for the policy definition"
  type        = string
  default     = "{}"
}

variable "policy_rule" {
  description = "The policy rule for the policy definition"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the policy definition"
  type        = map(string)
  default     = {}
}

