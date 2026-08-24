data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.project_name}-${var.environment}"

  az_a = data.aws_availability_zones.available.names[0]
  az_b = data.aws_availability_zones.available.names[1]

  public_subnets = {
    a = {
      cidr = "10.40.1.0/24"
      az   = local.az_a
    }
    b = {
      cidr = "10.40.2.0/24"
      az   = local.az_b
    }
  }

  app_subnets = {
    a = {
      cidr = "10.40.11.0/24"
      az   = local.az_a
    }
    b = {
      cidr = "10.40.12.0/24"
      az   = local.az_b
    }
  }

  db_subnets = {
    a = {
      cidr = "10.40.21.0/24"
      az   = local.az_a
    }
    b = {
      cidr = "10.40.22.0/24"
      az   = local.az_b
    }
  }
}
