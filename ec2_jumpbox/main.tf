# Create the keypair
resource "tls_private_key" "main_ec2_private" {
  count = 1

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main_deployer" {
  key_name   = "${var.project_name}_main_deployer_key"
  public_key = trimspace(tls_private_key.main_ec2_private[0].public_key_openssh)
}

resource "aws_instance" "web" {
  ami                         = "ami-07caf09b362be10b8"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.main_deployer.key_name
  vpc_security_group_ids      = [module.jump_box_security_group.security_group_id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true


  tags = {
    Name = "nat_main"
  }
}
