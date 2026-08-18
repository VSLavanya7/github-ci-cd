data "aws_iam_policy_document" "controller_assume_role" {

  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "controller" {

  name = "${var.project_name}-controller"

  assume_role_policy = data.aws_iam_policy_document.controller_assume_role.json
}


resource "aws_iam_role_policy" "controller" {

  name = "${var.project_name}-controller-policy"

  role = aws_iam_role.controller.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:UpdateAutoScalingGroup"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:DescribeTargetHealth"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "cloudwatch:PutMetricData"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "controller" {

  name = "${var.project_name}-controller-profile"

  role = aws_iam_role.controller.name
}