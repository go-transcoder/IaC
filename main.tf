
# use the registries module to create our modules
module "registries" {
  source = "./registries"

  aws_region        = "eu-north-1"
  aws_profile       = var.profile
  registries_prefix = var.project_name

  github_oidc_url = "https://token.actions.githubusercontent.com"

  registries_allowed_repos = [
    "repo:go-transcoder/transcoder:ref:refs/heads/main",
    "repo:go-transcoder/uploader:ref:refs/heads/main",
    "repo:go-transcoder/db-manager:ref:refs/heads/main",
  ]
  registries_names = [
    "transcoder",
    "uploader",
    "db_manager"
  ]
}

module "vpc" {
  source = "./vpc"

  env          = var.env
  project_name = var.project_name

  vpc_cidr        = var.vpc_cidr
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets
}

module "db" {
  source = "./db"

  env          = var.env
  project_name = var.project_name

  security_group_id = module.vpc.db_security_group_id
  subnet_id         = module.vpc.public_subnets[0]
  vpc_id            = module.vpc.vpc_id
}

module "ecs" {
  source = "./ecs"

  env          = var.env
  project_name = var.project_name
  region       = var.region

  task_definitions = {
    "db-manager" = {
      image : module.registries.repository_urls["db_manager"],
      tag: "main",
      env : [
        {
          name : "DB_NAME"
          value : var.db_config.db_name
        },
        {
          name : "DB_USER"
          value : var.db_config.db_user
        },
        {
          name : "DB_PASSWORD"
          value : var.db_config.db_password
        },
        {
          name : "DB_HOST"
          value : module.db.private_ip
        },
        {
          name : "DB_PORT"
          value : var.db_config.db_port
        }
      ]
    }
  }
}


#module "s3_lambda" {
#  source = "./s3Lambda"
#
#  bucket_name = "abboud131231231231namir-uploader-bucket"
#}
#
#module "batch" {
#  source = "./batch"
#
#  project_name = var.project_name
#  region       = var.region
#  s3_bucket    = module.s3_lambda.s3_bucket
#
#  vpc_id                         = module.vpc.vpc_id
#  compute_subnets                = module.vpc.private_subnets
#  vpc_endpoint_security_group_id = module.vpc_endpoint_security_group.security_group_id
#
#  docker_image_registry_url = module.registries.transcoder_repo_url
#  docker_image_tag          = "main"
#}
#
#module "eks" {
#  source = "./eksCluster"
#
#  region = var.region
#
#  vpc_id      = module.vpc.vpc_id
#  vpc_subnets = module.vpc.private_subnets
#
#  node_groups = {
#    one = {
#      name = "node-group-1"
#
#      instance_types = ["t3.small"]
#
#      min_size     = 1
#      max_size     = 3
#      desired_size = 1
#    }
#
#    two = {
#      name = "node-group-2"
#
#      instance_types = ["t3.small"]
#
#      min_size     = 1
#      max_size     = 3
#      desired_size = 1
#    }
#  }
#}