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