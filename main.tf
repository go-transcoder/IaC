terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source = "hashicorp/archive"
    }
    null = {
      source = "hashicorp/null"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

provider "aws" {
  alias   = "north"
  region  = "eu-north-1"
  profile = var.profile
}

locals {
  tags = {
    # This will set the name on the Ec2 instances launched by this compute environment
    Name = var.project_name
    Type = "Ec2"
  }
}