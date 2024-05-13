resource "aws_security_group" "this" {

  name        = "${var.project_name}-msk-sg"
  vpc_id      = var.vpc_id


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  for_each = var.security_group_rules

  # required
  type              = try(each.value.type, "ingress")
  from_port         = try(each.value.from_port, local.port)
  to_port           = try(each.value.to_port, local.port)
  protocol          = try(each.value.protocol, "tcp")
  security_group_id = aws_security_group.this.id

  # optional
  cidr_blocks              = try(each.value.cidr_blocks, null)
  description              = try(each.value.description, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
}