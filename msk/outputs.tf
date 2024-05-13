output "bootstrap_brokers" {
  value = split(",", aws_msk_cluster.kafka.bootstrap_brokers)
}