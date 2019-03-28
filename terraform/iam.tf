


resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-${var.app_name}-fargate-role"
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
  tags = "${merge(
          var.extra_tags,
          map("Name", "${var.environment}-${var.app_name}-fargate-role"),
          )}"
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
  role = "${aws_iam_role.ecs_execution_role.name}"
  policy = "${data.aws_iam_policy_document.app_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = "${aws_iam_role.ecs_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

