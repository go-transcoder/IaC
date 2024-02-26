variable "project_name" {
  type    = string
  default = null
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "vpc_endpoint_security_group_id" {
  type        = string
  description = "the security group used with the batch"
}

variable "compute_subnets" {
  type    = list(string)
  default = []
}

variable "region" {
  type    = string
  default = null
}

variable "s3_bucket" {
  description = "The S3 bucket to use in the batch module."
  type        = string
  default     = null
}

variable "docker_image_registry_url" {
  description = "The job definition container image, that the compute environment will start"
  type        = string
  default     = null
}

variable "docker_image_tag" {
  description = "The job definition container image tag"
  type        = string
  default     = null
}


