variable "region" {
  default = "eu-central-1"
}

provider "aws" {
  region = "${var.region}"
}

module "vpc-utm" {
  source = "terraform-aws-modules/vpc/aws"

  enable_dns_hostnames = true
  enable_dns_support   = true

  name = "utm-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]

  tags = {
    Terraform = "true"
    App       = "UTM"
  }
}

module "utm" {
  source     = "git@github.com:cloudreach/squid-utm.git//terraform?ref=v0.1"
  vpc_id     = "${module.vpc-utm.vpc_id}"
  aws_region = "${var.region}"

  environment = "dev"

  lb_subnets      = ["${module.vpc-utm.public_subnets}"]
  fargate_subnets = ["${module.vpc-utm.public_subnets}"]

  desired_count = 2

  extra_tags = {
    Terraform = "true"
    App       = "UTM"
  }
}

output "test_curl" {
  value = "${module.utm.test_curl}"
}
