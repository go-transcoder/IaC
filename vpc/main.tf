# Filter out local zones, which are not currently supported
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.0"

  name = var.project_name
  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true

  public_route_table_tags  = { Name = "${var.project_name}-public" }
  public_subnet_tags       = { Name = "${var.project_name}-public" }
  private_route_table_tags = { Name = "${var.project_name}-private" }
  private_subnet_tags      = { Name = "${var.project_name}-private" }


  enable_dhcp_options      = true
  dhcp_options_domain_name = "ec2.internal"

  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]
}
