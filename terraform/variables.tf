
variable "aws_region" {
  description = "AWS region to launch servers."
}

variable "vpc_id" {
}

variable "environment" {
	default = "dev"
}

variable "app_name" {
	default = "utm-squid"
}

variable "app_port" {
	default = 3128
}

variable "fargate_image" {
  default = "cloudreach/squid-utm:1.0"
  
}

# Additional tags to apply to all tagged resources.
variable "extra_tags" {
  type = "map"
}

variable "internal" {
  default = "false"
}

variable "fargate_subnets" {
  default = []
}

variable "lb_subnets" {
  default = []
}



# How often to check the liveliness of the container
variable "health_check_interval" {
  default = "30"
}

variable "desired_count" {
  description = "Fargate count"
  default     = 2
}

variable "max_count" {
  description = "Max Fargate count"
  default     = 20
}


# The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused
variable "deregistration_delay" {
  default = "5"
}

variable "whitelist_aws_region" {
  description = "URL filter for AWS region"
  default = "eu-west-1,eu-west-2,eu-central-1"
}

variable "whitelist_url" {
  description = "permitted URL filter"
  default = "www.cloudreach.com,www.google.com"
}

variable "url_block_all" {
  description = "deny all other access to this proxy"
  default = "false"
}

variable "blacklist_url" {
  description = "blocked URL filter"
  default = "www.exploit-db.com"
}

variable "allowed_cidrs" {
  description = "Comma separated list of allowed CIDR ranges permitted to use the Proxy"
  default = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
}

