########
### Creating the EC2 instance
### for the batch compute environment



### Note that the EC2 instance needs the ECS policies
### because Compute environments contain the Amazon ECS container instances that are used to run containerized batch jobs.

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_instance_role" {
  name               = "ec2_instance_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.execution_role_permissions.arn
}

resource "aws_iam_instance_profile" "ec2_instance_role" {
  name = "ec2_instance_role"
  role = aws_iam_role.ec2_instance_role.name
}

### Create the Batch compute environment role
### should contains AWSBatchServiceRole policy

data "aws_iam_policy_document" "batch_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aws_batch_service_role" {
  name               = "aws_batch_service_role"
  assume_role_policy = data.aws_iam_policy_document.batch_assume_role.json
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_batch_compute_environment" "transcode_compute" {
  compute_environment_name = "transcodingService"

  compute_resources {
    type = "EC2"

    instance_role = aws_iam_instance_profile.ec2_instance_role.arn

    min_vcpus     = 4
    max_vcpus     = 16
    desired_vcpus = 4

    instance_type = [
      "m5.large",
      "r5.large"
    ]

    security_group_ids = [
      module.vpc_endpoint_security_group.security_group_id,
    ]

    subnets = module.vpc.private_subnets

    tags = {
      Name = var.project_name
      Type = "Ec2"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role]

  tags = local.tags
}

resource "aws_batch_scheduling_policy" "high_priority" {
  name = "HighPriorityTranscodeQueue"

  fair_share_policy {
    compute_reservation = 1
    share_decay_seconds = 3600

    share_distribution {
      share_identifier = "A1*"
      weight_factor    = 0.1
    }

    share_distribution {
      share_identifier = "A2"
      weight_factor    = 0.2
    }
  }

  tags = {
    JobQueue = "High priority job queue"
  }
}

resource "aws_batch_job_queue" "transcode" {
  name                  = "HighPriorityTranscodeQueue"
  priority              = 99
  scheduling_policy_arn = aws_batch_scheduling_policy.high_priority.arn
  compute_environments  = [aws_batch_compute_environment.transcode_compute.arn]
  state                 = "ENABLED"
}

// ##############################
// Execution Role ###############
// ##############################
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-batch-execution-role"
  assume_role_policy = data.aws_iam_policy_document.batch_execution_role_assume_role_policy.json
}

data "aws_iam_policy_document" "batch_execution_role_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.execution_role_permissions.arn
}

resource "aws_iam_policy" "execution_role_permissions" {
  name        = "ecs_read_from_s3"
  description = "read objects from s3 bucket"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:HeadObject",
          "s3:PutObject",
        ],
        Resource = "arn:aws:s3:::*/*",
      }
    ],
  })
}


resource "aws_batch_job_definition" "transcode_job_definition" {
  name                 = "video-transcode-job-definition"
  type                 = "container"
  container_properties = jsonencode({
    command              = [],
    image   = "023231733398.dkr.ecr.eu-north-1.amazonaws.com/my-transcoding-example-transcoding:main"
#    command              = ["ls", "-la"]
#    image                = "busybox"
    resourceRequirements = [
      {
        type  = "VCPU"
        value = "1"
      },
      {
        type  = "MEMORY"
        value = "1024"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options   = {
        awslogs-group         = aws_cloudwatch_log_group.this.id
        awslogs-region        = var.region
        awslogs-stream-prefix = var.project_name
      }
    }
    volumes = [
      {
        host = {
          sourcePath = "/tmp"
        }
        name = "tmp"
      }
    ]

    environment = [
      {
        name  = "INPUT_S3_BUCKET"
        value = aws_s3_bucket.uploader_bucket.bucket
      },
      {
        name  = "AWS_REGION"
        value = "us-east-1"
      },
      {
        name  = "UPLOADER_APP_UPLOAD_PATH"
        value = "/tmp"
      }
    ]
  })

  timeout {
    attempt_duration_seconds = 60
  }

  retry_strategy {
    attempts = 3
    evaluate_on_exit {
      action       = "RETRY"
      on_exit_code = 1
    }
    evaluate_on_exit {
      action       = "EXIT"
      on_exit_code = 0
    }
  }
  tags = {
    JobDefinition = "video-transcode-job-definition"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/batch/${var.project_name}"
  retention_in_days = 1
}