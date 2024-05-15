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
