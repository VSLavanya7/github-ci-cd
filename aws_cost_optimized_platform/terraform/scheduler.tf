resource "aws_iam_role" "scheduler" {
  name = "${local.name}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "scheduler_invoke" {
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "lambda:InvokeFunction"
      Resource = aws_lambda_function.wakeup_stop.arn
    }]
  })
}

resource "aws_scheduler_schedule" "hourly_stop" {
  name                         = "${local.name}-hourly-stop"
  schedule_expression          = "rate(1 hour)"
  schedule_expression_timezone = "Europe/Oslo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.wakeup_stop.arn
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({})
  }
}
