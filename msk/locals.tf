locals {
  tags = {
    Name = var.project_name
    Env  = var.env
  }

  port = 9092
}