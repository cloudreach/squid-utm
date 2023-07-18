resource "aws_security_group" "fargate" {
  name        = format("%s-%s-sg", var.environment, var.app_name)
  description = format("%s-%s-sg", var.environment, var.app_name)
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.extra_tags,
    { "Name" = format("%s-%s-sg", var.environment, var.app_name) },
  )
}
