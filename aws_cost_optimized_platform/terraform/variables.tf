variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
}

variable "project_name" {
  type        = string
  default     = "cost-optimized-app"
}

variable "environment" {
  type        = string
  default     = "production"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID"
}

variable "controller_subnet_id" {
  type        = string
  description = "Private subnet where controller will run"
}

variable "app_asg_name" {
  type        = string
  description = "Existing application Auto Scaling Group"
}

variable "app_target_group_arn" {
  type        = string
  description = "Existing application ALB target group ARN"
}

variable "github_org" {
  type        = string
  description = "GitHub organization/user"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository name"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "controller_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "controller_ami_id" {
  type        = string
  description = "AMI for controller"
}

variable "controller_key_name" {
  type        = string
  default     = null
}

variable "active_user_timeout_minutes" {
  type    = number
  default = 30
}

variable "shutdown_hour" {
  type    = number
  default = 17
}

variable "shutdown_timezone" {
  type    = string
  default = "Europe/Oslo"
}