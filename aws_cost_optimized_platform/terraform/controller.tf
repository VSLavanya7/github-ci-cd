resource "aws_security_group" "controller" {

  name        = "${var.project_name}-controller"
  description = "Controller security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Application traffic from ALB"

    from_port = 8080
    to_port   = 8080

    protocol = "tcp"

    security_groups = [
      "sg-0a94bf7d398de6771"
    ]
  }

  egress {
    description = "Outbound HTTPS"

    from_port = 443
    to_port   = 443

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.project_name}-controller"
  }
}

resource "aws_instance" "controller" {

  ami = var.controller_ami_id

  instance_type = var.controller_instance_type

  subnet_id = var.controller_subnet_id

  iam_instance_profile = aws_iam_instance_profile.controller.name

  vpc_security_group_ids = [
    aws_security_group.controller.id
  ]

  key_name = var.controller_key_name

  user_data = file("${path.module}/../controller/bootstrap.sh")

  tags = {
    Name = "${var.project_name}-controller"
    Role = "wake-controller"
  }
}