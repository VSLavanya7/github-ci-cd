data "archive_file" "shutdown_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/shutdown"
  output_path = "${path.module}/../lambda/shutdown.zip"
}

resource "aws_lambda_function" "shutdown" {
  filename         = "${path.module}/../lambda/shutdown.zip"
  source_code_hash = data.archive_file.shutdown_zip.output_base64sha256
  function_name    = "${var.project_name}-shutdown"
  role             = aws_iam_role.lambda.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  timeout          = 10
  memory_size      = 128

  vpc_config {
    subnet_ids         = [var.controller_subnet_id]
    security_group_ids = [var.alb_security_group_id]
  }

  environment {
    variables = {
      ASG_NAME         = var.app_asg_name
      METRIC_NAMESPACE = var.project_name
      METRIC_NAME      = "UserActivityCount"
    }
  }
}