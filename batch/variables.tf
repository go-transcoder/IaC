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
