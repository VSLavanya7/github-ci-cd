data "aws_iam_policy_document" "github_assume_role" {

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_org}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {

  name = "${var.project_name}-github-actions"

  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

resource "aws_iam_openid_connect_provider" "github" {

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name = "github-actions-oidc"
  }
}

resource "aws_iam_role_policy" "github_terraform" {

  name = "${var.project_name}-terraform"

  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "autoscaling:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "iam:*",
          "lambda:*",
          "events:*",
          "scheduler:*",
          "cloudwatch:*"
        ]

        Resource = "*"
      }
    ]
  })
}