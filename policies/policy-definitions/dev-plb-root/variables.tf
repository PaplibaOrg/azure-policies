variable "environment" {
  description = "Environment name (not used for policy definitions, but required by module)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Base tags object (not used for policy definitions, but required by module)"
  type = object({
    owner       = string
    application = string
  })
  default = {
    owner       = ""
    application = ""
  }
}

variable "additional_tags" {
  description = "Additional tags (not used for policy definitions, but required by module)"
  type        = map(string)
  default     = {}
}

