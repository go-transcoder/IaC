
# the load balancer that will be used with the upload app
resource "aws_lb" "upload_app" {
  name               = "upload-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnets
}

# the default target group listening on port 80 for the upload_app lb
# Create a target group
resource "aws_lb_target_group" "upload_app_target_group_port_80" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.upload_app.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.upload_app_target_group_port_80.id
    type             = "forward"
  }
}