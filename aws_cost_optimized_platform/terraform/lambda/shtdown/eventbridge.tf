# Rule at 17:00 Europe/Oslo daily
resource "aws_cloudwatch_event_rule" "shutdown_daily" {
  name                = "${var.project_name}-shutdown-daily"
  schedule_expression = "cron(0 ${var.shutdown_hour} * * ? *)"
}

resource "aws_cloudwatch_event_target" "shutdown_daily" {
  rule      = aws_cloudwatch_event_rule.shutdown_daily.name
  target_id = "ShutdownLambda"
  arn       = aws_lambda_function.shutdown.arn
}

resource "aws_lambda_permission" "allow_eventbridge_shutdown" {
  statement_id  = "AllowEventBridgeShutdown"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.shutdown.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.shutdown_daily.arn
}

# Optional: additional hourly rule after 17:00 if you want explicit hourly checks
# (You can also rely on a single daily rule + logic inside Lambda.)