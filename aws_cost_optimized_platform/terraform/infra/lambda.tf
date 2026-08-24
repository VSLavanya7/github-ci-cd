data "archive_file" "wakeup_start" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/wakeup_start.py"
  output_path = "${path.module}/wakeup_start.zip"
}

data "archive_file" "wakeup_stop" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/wakeup_stop.py"
  output_path = "${path.module}/wakeup_stop.zip"
}

resource "aws_iam_role" "lambda" {
  name = "${local.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_control" {
  name = "${local.name}-lambda-control"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:SetDesiredCapacity"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.state.arn
      }
    ]
  })
}

resource "aws_lambda_function" "wakeup_start" {
  function_name = "${local.name}-wakeup-start"
  role          = aws_iam_role.lambda.arn
  handler       = "wakeup_start.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.wakeup_start.output_path
  source_code_hash = data.archive_file.wakeup_start.output_base64sha256

  environment {
    variables = {
      ASG_NAME    = aws_autoscaling_group.app.name
      STATE_TABLE = aws_dynamodb_table.state.name
    }
  }
}

resource "aws_lambda_function" "wakeup_stop" {
  function_name = "${local.name}-wakeup-stop"
  role          = aws_iam_role.lambda.arn
  handler       = "wakeup_stop.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.wakeup_stop.output_path
  source_code_hash = data.archive_file.wakeup_stop.output_base64sha256

  environment {
    variables = {
      ASG_NAME       = aws_autoscaling_group.app.name
      STATE_TABLE    = aws_dynamodb_table.state.name
      IDLE_MINUTES   = "60"
      SHUTDOWN_HOUR = "17"
    }
  }
}
14. Add Lambda target routing
Add to infra/alb.tf:
text
resource "aws_lb_target_group" "wakeup_lambda" {
  name        = "${local.name}-wake-tg"
  target_type = "lambda"
}
Register the Lambda:
text
resource "aws_lb_target_group_attachment" "wakeup_lambda" {
  target_group_arn = aws_lb_target_group.wakeup_lambda.arn
  target_id        = aws_lambda_function.wakeup_start.arn
}
Allow ALB invocation:
text
resource "aws_lambda_permission" "alb_invoke_wakeup" {
  statement_id  = "AllowAlbInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.wakeup_start.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.wakeup_lambda.arn
}
Add a listener rule:
text
resource "aws_lb_listener_rule" "wakeup" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/wake-up"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wakeup_lambda.arn
  }
}
