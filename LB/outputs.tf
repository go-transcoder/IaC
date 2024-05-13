output "upload_app_lb_arn" {
  value = aws_lb.upload_app.arn
}

output "upload_app_lb_dns" {
  value = aws_lb.upload_app.dns_name
}

output "upload_app_target_group_80" {
  value = aws_lb_target_group.upload_app_target_group_port_80.arn
}