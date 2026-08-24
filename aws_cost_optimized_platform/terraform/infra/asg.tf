resource "aws_autoscaling_group" "app" {
  name                = "${local.name}-app-asg"
  min_size            = 0
  desired_capacity    = 0
  max_size            = 2
  vpc_zone_identifier = [for subnet in aws_subnet.app : subnet.id]

  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-app-instance"
    propagate_at_launch = true
  }
}
