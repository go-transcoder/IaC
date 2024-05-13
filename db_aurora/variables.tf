variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "security_group_rules" {
  type = any
}

variable "subnet_group_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}
