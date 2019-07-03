variable "aws_region" {
  description = "AWS region to launch servers."
  type        = string
}

variable "vpc_id" {}

variable "environment" {
  default = "dev"
  type    = string
}

variable "app_name" {
  default = "utm-squid"
  type    = string
}

variable "app_port" {
  default = 3128
  type    = number
}

variable "fargate_image" {
  default = "cloudreach/squid-utm:1.1"
  type    = string
}

# Additional tags to apply to all tagged resources.
variable "extra_tags" {
  type = "map"
}

variable "internal" {
  default = false
  type    = bool
}

variable "fargate_subnets" {
  default = []
  type    = list(string)
}

variable "lb_subnets" {
  default = []
  type    = list(string)
}

# How often to check the liveliness of the container
variable "health_check_interval" {
  default = 30
  type    = number
}

variable "desired_count" {
  description = "Fargate count"
  default     = 2
  type        = number
}

variable "max_count" {
  description = "Max Fargate count"
  default     = 20
  type        = number
}

# The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused
variable "deregistration_delay" {
  default = 5
  type    = number
}

variable "whitelist_aws_region" {
  description = "URL filter for AWS region"
  default     = "eu-west-1,eu-west-2,eu-central-1"
  type        = string
}

variable "whitelist_url" {
  description = "permitted URL filter"
  default     = "www.cloudreach.com,www.google.com"
  type        = string
}

variable "url_block_all" {
  description = "deny all other access to this proxy"
  type        = bool
  default     = true
}

variable "blacklist_url" {
  description = "blocked URL filter"
  default     = "www.exploit-db.com"
  type        = string
}

variable "allowed_cidrs" {
  description = "Comma separated list of allowed CIDR ranges permitted to use the Proxy"
  default     = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
  type        = string
}
