variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = null
}

variable "aws_profile" {
  description = "AWS region"
  type        = string
  default     = null
}

variable "registries_prefix" {
  description = "Prefix of the registries"
  type        = string
  default     = null
}

variable "github_oidc_url" {
  description = "The url of the oidc for github, we use this variable to check if the oidc is created. if not we creat otherwise we use the existing one"
  type        = string
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