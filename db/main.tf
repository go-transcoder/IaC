# Create the keypair
resource "tls_private_key" "this" {
  count = 1

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}DeployerKey"
  public_key = trimspace(tls_private_key.this[0].public_key_openssh)
}


resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  key_name                    = aws_key_pair.this.key_name
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true # we want a public IP so we can access it through SSH
  iam_instance_profile        = aws_iam_instance_profile.this.name

  tags = local.tags
}