
/*====
ECS cluster
======*/
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-${var.app_name}"
  tags = "${merge(
          var.extra_tags,
          map("Name", "${var.environment}-${var.app_name}"),
          )}"  
}


/*====
ECS task definitions
======*/


resource "aws_cloudwatch_log_group" "cwlog" {
  name = "/ecs/${var.environment}-${var.app_name}"
  retention_in_days = 30

  tags = "${merge(
          var.extra_tags,
          map("Name", "${var.environment}-${var.app_name}"),
          )}"
}



resource "aws_ecs_task_definition" "squid" {
  family                   = "${var.environment}-${var.app_name}"
  container_definitions = <<EOF
[
  {
    "name": "${var.app_name}",
    "image": "${var.fargate_image}",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/${var.environment}-${var.app_name}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "environment": [
      { "name": "ALLOWED_CIDRS", "value": "${var.allowed_cidrs}" },
      { "name": "AWS_REGIONS", "value": "${var.whitelist_aws_region}" },
      { "name": "SQUID_WHITELIST", "value": "${var.whitelist_url}" },
      { "name": "SQUID_BLACKLIST", "value": "${var.blacklist_url}" },
      { "name": "NO_WHITELIST", "value": "${var.url_block_all}" }
    ],
    "portMappings": [
      {
        "containerPort": ${var.app_port}
      }
    ]
  }
]
EOF

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

resource "aws_ecs_service" "service" {
    name            = "${var.environment}-${var.app_name}"
    cluster         = "${aws_ecs_cluster.main.id}"
    task_definition = "${aws_ecs_task_definition.squid.family}:${aws_ecs_task_definition.squid.revision}"
    launch_type     = "FARGATE"
    desired_count   = "${var.desired_count}"

    load_balancer {
        target_group_arn  = "${aws_lb_target_group.main.arn}"
        container_name    = "${var.app_name}"
        container_port    = "${var.app_port}"
    }

    network_configuration{
      subnets         = ["${var.fargate_subnets}"]
      security_groups = ["${aws_security_group.fargate.id}"]
      assign_public_ip = true
    }

    depends_on = [
      "aws_lb.main",
      "aws_ecs_task_definition.squid"
      ]
}
