variable "environment" {
  description = "Environment name for tagging purposes"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Base tags object"
  type = object({
    owner       = string
    application = string
  })
  default = {
    owner       = "platform-team"
    application = "policy-management"
  }
}

variable "additional_tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default = {
    managedBy = "terraform"
  }
}

