variable "region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "my-transcoding-example"
}

variable "env" {
  default = "dev"
}

variable "terraform_state_bucket" {
  description = "The bucket where we store the state file"
  type        = string
}

variable "profile" {
  default = "admin"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "db_config" {
  type = object({
    db_name: string,
    db_user: string,
    db_password: string,
    db_port: string
  })
}