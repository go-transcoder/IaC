terraform {
  backend "s3" {
    bucket         = "abboud131231231231namir-my-transcoding-tf-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
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
  region  = var.region
}

provider "aws" {
  alias   = "north"
  region  = "eu-north-1"
}

// use the registries module to create our modules
module "registries" {
  source = "./registries"

  aws_region        = "eu-north-1"
  aws_profile       = var.profile
  registries_prefix = var.project_name

  github_oidc_url = "https://token.actions.githubusercontent.com"

  transcoder_registry_name = "transcoder"
  uploader_registry_name   = "uploader"

  registries_allowed_repos = [
    "repo:go-transcoder/transcoder:ref:refs/heads/main",
    "repo:go-transcoder/uploader:ref:refs/heads/main",
  ]
}

module "s3_lambda" {
  source = "./s3Lambda"

  bucket_name = "abboud131231231231namir-uploader-bucket"
}

module "batch" {
  source = "./batch"

  project_name = var.project_name
  region       = var.region
  s3_bucket    = module.s3_lambda.s3_bucket

  vpc_id                         = module.vpc.vpc_id
  compute_subnets                = module.vpc.private_subnets
  vpc_endpoint_security_group_id = module.vpc_endpoint_security_group.security_group_id

  docker_image_registry_url = module.registries.transcoder_repo_url
  docker_image_tag          = "main"
}

module "eks" {
  source = "./eksCluster"

  region = var.region

  vpc_id      = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets

  node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }
  }
}