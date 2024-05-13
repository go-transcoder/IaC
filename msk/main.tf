# Cluster
resource "aws_kms_key" "kafka_kms_key" {
  description = "Key for Apache Kafka"
}

resource "aws_cloudwatch_log_group" "kafka_log_group" {
  name = "kafka_broker_logs"
}

#resource "aws_msk_configuration" "kafka_config" {
#  kafka_versions    = ["3.4.0"]
#  name              = "${var.project_name}-config"
#  server_properties = <<EOF
#auto.create.topics.enable = true
#delete.topic.enable = true
#EOF
#}

resource "aws_msk_cluster" "kafka" {
  cluster_name           = "${var.project_name}-msk"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = length(var.subnets)
  broker_node_group_info {
    instance_type = "kafka.m5.large" # default value
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
    client_subnets = var.subnets
    security_groups = [aws_security_group.this.id]
  }
  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
    }
    encryption_at_rest_kms_key_arn = aws_kms_key.kafka_kms_key.arn
  }
#  configuration_info {
#    arn      = aws_msk_configuration.kafka_config.arn
#    revision = aws_msk_configuration.kafka_config.latest_revision
#  }
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.kafka_log_group.name
      }
    }
  }
}