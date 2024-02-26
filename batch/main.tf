resource "aws_batch_compute_environment" "transcode_compute" {
  compute_environment_name = "transcodingService"

  compute_resources {
    type = "EC2"

    instance_role = aws_iam_instance_profile.ec2_instance_role.arn

    min_vcpus     = 0
    max_vcpus     = 16
    desired_vcpus = 0

    instance_type = [
      "m5.large",
      "r5.large"
    ]

    security_group_ids = [
      var.vpc_endpoint_security_group_id,
    ]

    subnets = var.compute_subnets

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

resource "aws_batch_job_definition" "transcode_job_definition" {
  name                 = "video-transcode-job-definition"
  type                 = "container"
  container_properties = jsonencode({
    command              = [],
    image                = "${var.docker_image_registry_url}:${var.docker_image_tag}"
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
        value = var.s3_bucket
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

    executionRoleArn = aws_iam_role.ecs_task_execution_role.arn
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