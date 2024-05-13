variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "security_group_rules" {
  type = any
}

variable "kafka_version" {
  type = string
  default = "3.4.0"
}
