aws_region         = "eu-central-1"
aws_account_id     = "261247365620"
project_name       = "cost-optimized-app"
environment        = "Testing"

vpc_id             = "vpc-xxxx"
private_app_subnet_ids = ["subnet-xxxx", "subnet-yyyy"]
controller_subnet_id   = "subnet-ctrl"

app_asg_name           = "my-existing-app-asg"
app_target_group_arn   = "arn:aws:elasticloadbalancing:..."
alb_security_group_id  = "sg-xxxx"

github_org        = "mycompany"
github_repository = "aws-cost-optimized-app"
github_branch     = "main"

shutdown_hour     = 17
shutdown_timezone = "Europe/Oslo"