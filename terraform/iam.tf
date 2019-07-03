resource "aws_iam_role" "ecs_execution_role" {
  name = format("%s-%s-fargate-role", var.environment, var.app_name)
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = merge(
    var.extra_tags,
    map("Name", format("%s-%s-fargate-role", var.environment, var.app_name)),
  )
}

data "aws_iam_policy_document" "app_policy" {
  statement {
    actions = [
      "ecs:DescribeClusters",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "app_policy_pl" {
  name = "app_policy"
  role = aws_iam_role.ecs_execution_role.name
  policy = data.aws_iam_policy_document.app_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
