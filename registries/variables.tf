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

variable "registries_names" {
  description = "List of the registries names to be created"
  type        = list(string)
  default     = []
}

variable "transcoder_registry_name" {
  description = "The name of the transcoding registry"
  type        = string
  default     = null
}

variable "uploader_registry_name" {
  description = "The name of the uploader registry"
  type        = string
  default     = null
}

variable "registries_allowed_repos" {
  description = "List of the repositories that has access to the registries"
  type        = list(string)
  default     = []
}