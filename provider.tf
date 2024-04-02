terraform {
  backend "s3" {
    bucket = "abboud131231231231namir-my-transcoding-tf-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

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
  region = var.region
}

provider "aws" {
  alias  = "north"
  region = "eu-north-1"
}
