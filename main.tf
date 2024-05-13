# use the registries module to create our modules
module "registries" {
  source = "./registries"

  aws_region        = "eu-north-1"
  aws_profile       = var.profile
  registries_prefix = var.project_name

  github_oidc_url = "https://token.actions.githubusercontent.com"

  # here we are adding the role to be assumed by the github workflows
  # TODO: we have to remove it from here
  registries_allowed_repos = [
    "repo:go-transcoder/transcoder:ref:refs/heads/main",
    "repo:go-transcoder/uploader:ref:refs/heads/main",
    "repo:go-transcoder/infrastructure:ref:refs/heads/main",
  ]
  registries_names = [
    "transcoder",
    "uploader",
  ]
}

module "vpc" {
  source = "./vpc"

  env          = var.env
  project_name = var.project_name

  vpc_cidr         = var.vpc_cidr
  private_subnets  = var.vpc_private_subnets
  public_subnets   = var.vpc_public_subnets
  database_subnets = var.db_config.db_engine == "postgresql-serverless" ? var.vpc_database_subnets : []
}

module "jump_box" {
  source = "./ec2_jumpbox"

  env          = var.env
  project_name = var.project_name

  subnet_id = module.vpc.public_subnets[0]
  vpc_id    = module.vpc.vpc_id
}

module "db" {
  source = "./db"

  count = var.db_config.db_engine == "postgresql" ? 1 : "0"

  env          = var.env
  project_name = var.project_name

  security_group_id = module.vpc.db_security_group_id
  subnet_id         = module.vpc.public_subnets[0]
  vpc_id            = module.vpc.vpc_id
}

module "db_aurora" {
  source = "./db_aurora"

  count = var.db_config.db_engine == "postgresql-serverless" ? 1 : "0"

  env          = var.env
  project_name = var.project_name

  db_username = var.db_config.db_user
  db_password = var.db_config.db_password

  vpc_id            = module.vpc.vpc_id
  subnet_group_name = module.vpc.database_subnet_group_name

  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
    sg_ingress = {
      source_security_group_id = module.vpc.ecs_security_group_id
    }
    batch_ingress = {
      source_security_group_id = module.vpc.vpc_endpoint_security_group
      # we are using this security group for batch # TODO: change this
    }
    bastion = {
      source_security_group_id = module.jump_box.security_group_id
    }
  }
}

module "ecs" {
  source = "./ecs"

  env          = var.env
  project_name = var.project_name
  region       = var.region

  task_definitions = {
    "uploader" = {
      family : "${var.project_name}-uploader"
      image : module.registries.repository_urls["uploader"],
      repository_name: module.registries.repository_names["uploader"]

      # Later the uploaded project will update the task definition.
      env : [
        {
          name : "DBNAME"
          value : var.db_config.uploader.name
        },
        {
          name : "DBUSER"
          value : var.db_config.uploader.user
        },
        {
          name : "DBPASS"
          value : var.db_config.uploader.password
        },
        {
          name : "DBHOST"
          value : module.db_aurora[0].host_url
        },
        {
          name : "DBPORT"
          value : var.db_config.db_port
        },
        {
          name : "INPUT_S3_BUCKET"
          value : module.s3_lambda.s3_bucket
        },
        {
          name : "PORT"
          value : 4000
        },
        {
          name : "KAFKAHOST"
          value : join(",", module.msk.bootstrap_brokers)
        },
        {
          name : "KAFKATOPIC"
          value : "video-transcode-status"
        }
      ]
      portMapping = [
        {
          containerPort = 4000
          hostPort      = 4000
        }
      ]
    }
  }

  services = {
    "uploader-app" : {
      task_definition : "uploader"
      desired_count : 1
      deployment_maximum_percent : 100
      deployment_minimum_healthy_percent : 0
      subnets_list : module.vpc.private_subnets
      security_group : module.vpc.ecs_security_group_id
      load_balancer : [
        {
          target_group_arn : module.lb.upload_app_target_group_80
          container_port : 4000
        }
      ]
    }
  }
}

module "s3_lambda" {
  source = "./s3Lambda"

  bucket_name = "abboud131231231231namir-uploader-bucket"
}

#module "batch" {
#  source = "./batch"
#
#  project_name = var.project_name
#  region       = var.region
#  s3_bucket    = module.s3_lambda.s3_bucket
#
#  vpc_id                         = module.vpc.vpc_id
#  compute_subnets                = module.vpc.private_subnets
#  vpc_endpoint_security_group_id = module.vpc.vpc_endpoint_security_group
#
#  docker_image_registry_url = module.registries.repository_urls["transcoder"]
#  docker_image_tag          = "main"
#
#  job_definitions = {
#    transcoder = {
#      image = "${module.registries.repository_urls["transcoder"]}:main"
#      # TODO: change the tag, change the definition in the CI
#
#      volumes = [
#        {
#          host = {
#            sourcePath = "/tmp"
#          }
#          name = "tmp"
#        }
#      ]
#
#      environment = [
#        {
#          name  = "INPUT_S3_BUCKET"
#          value = module.s3_lambda.s3_bucket
#        },
#        {
#          name  = "AWS_REGION"
#          value = "us-east-1"
#        },
#        {
#          name  = "UPLOADER_APP_UPLOAD_PATH"
#          value = "/tmp"
#        },
#        {
#          name : "KAFKAHOST"
#          value : join(",", module.msk.bootstrap_brokers)
#        },
#        {
#          name : "KAFKATOPIC"
#          value : "video-transcode-status"
#        },
#        {
#          name : "DBUSER"
#          value : var.db_config.transcoder.user
#        },
#        {
#          name : "DBPASS"
#          value : var.db_config.transcoder.password
#        },
#        {
#          name : "DBHOST"
#          value : module.db_aurora[0].host_url
#        },
#        {
#          name : "DBNAME"
#          value : var.db_config.transcoder.name
#        },
#
#      ]
#    }
#  }
#}

module "lb" {
  source = "./LB"

  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.public_subnets
  security_group_id = module.vpc.lb_security_group
}

module "msk" {
  source = "./msk"

  env          = var.env
  project_name = var.project_name

  vpc_id  = module.vpc.vpc_id
  subnets = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
    bastion = {
      source_security_group_id = module.jump_box.security_group_id
    }
  }
}

module "secrets" {
  source = "./secrets"

  env          = var.env
  project_name = var.project_name

  secrets = {
    PIVOT_KEY : module.jump_box.private_key_pem
    VAULT_PASS : var.vault_pass
    MAIN_DB_PASS : var.db_config.db_password
    UPLOADER_DB_PASS : var.db_config.uploader.password
    TRANSCODER_DB_PASS : var.db_config.transcoder.password
    KAFKA_BOOTSTRAP_STRING : join(",", module.msk.bootstrap_brokers)
  }
}

# output variables for the ansible project
resource "local_file" "tf_ansible_vars_file_new" {
  content = <<-DOC
    # Ansible vars_file containing variable values from Terraform.
    # Generated by Terraform mgmt configuration.

    tf_private_subnets:
    ${yamlencode(module.vpc.private_subnets)}

    tf_ecs_security_group_id: ${module.vpc.ecs_security_group_id}

    tf_aurora_db_host: ${module.db_aurora[0].host_url}
    tf_input_s3_bucket: ${module.s3_lambda.s3_bucket}

    tf_kafka_brokers_urls: ${join(",", module.msk.bootstrap_brokers)}
    tf_ecs_cluster: ${module.ecs.cluster}

    tf_publisher_load_balancer_target_group_arn: ${module.lb.upload_app_target_group_80}
    tf_publisher_execution_role_arn: ${module.ecs.task_execution_role}
    tf_publisher_task_role_arn: ${module.ecs.task_role}
    DOC
  filename = "./tf_ansible_vars_file.yml"
}