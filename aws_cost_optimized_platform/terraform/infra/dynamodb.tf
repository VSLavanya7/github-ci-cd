resource "aws_dynamodb_table" "state" {
  name         = "${local.name}-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "application"

  attribute {
    name = "application"
    type = "S"
  }

  tags = {
    Name = "${local.name}-state"
  }
}
This table stores:
text
application = main
state = SLEEPING, STARTING, RUNNING
lastActivityEpoch = timestamp
