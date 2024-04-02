variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ami_id" {
  type = string
  default = "ami-080e1f13689e07408"
}

variable "instance_type" {
  type = string
#  default = "c6a.xlarge"
  default = "t2.micro"
}

variable "security_group_id" {
  type = string
}