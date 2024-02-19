variable "registries_prefix" {
  description = "Prefix of the registries"
  type        = string
  default     = null
}

variable "registries_names" {
  description = "List of the registries names to be created"
  type        = list(string)
  default     = []
}

variable "registries_allowed_repos" {
  description = "List of the repositories that has access to the registries"
  type        = list(string)
  default     = []
}

variable "registries_provider" {
  description = "The provider alias to be used to create the registries. This to specify the right Zone for the registries"
  type        = string
  default     = null
}

variable "registries_oidc_role_name" {
  description = "The role to be assumed by the OIDC to access the registries"
  type        = string
  default     = null
}
