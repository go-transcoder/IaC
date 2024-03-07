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

  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true

  enable_dns_hostnames = true

  public_route_table_tags  = { Name = "${var.project_name}-public" }
  public_subnet_tags       = { Name = "${var.project_name}-public" }
  private_route_table_tags = { Name = "${var.project_name}-private" }
  private_subnet_tags      = { Name = "${var.project_name}-private" }


  enable_dhcp_options      = true
  dhcp_options_domain_name = "ec2.internal"

  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]
}

module "vpc_endpoint_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-vpc-endpoint"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule = "https-443-tcp"
      description = "HTTPS from VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  ingress_with_self = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Container to VPC endpoint service"
      self        = true
    },
  ]


  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["https-443-tcp"]
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.1.1"

  vpc_id             = module.vpc.vpc_id
  # The security group for the VPC endpoint must have an inbound rule that allows traffic from port 443
  security_group_ids = [module.vpc_endpoint_security_group.security_group_id]

  # If you use VPC private endpoints for a fully private cluster, then be sure that you have the following endpoints:
  # com.amazonaws.region.ec2 (interface endpoint)
  # com.amazonaws.region.ecr.api (interface endpoint)
  # com.amazonaws.region.ecr.dkr (interface endpoint)
  # com.amazonaws.region.s3 (gateway endpoint)
  # com.amazonaws.region.sts (interface endpoint)

  endpoints = {
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
    ec2 = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
    }
  }

  tags = local.tags
}