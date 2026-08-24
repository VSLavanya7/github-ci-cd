variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "project_name" {
  type    = string
  default = "cost-optimized-app"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "vpc_id" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "controller_subnet_id" {
  type = string
}

variable "app_asg_name" {
  type = string
}

variable "app_target_group_arn" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "github_org" {
  type = string
}

variable "github_repository" {
  type = string
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "shutdown_hour" {
  type    = number
  default = 17
}

variable "shutdown_timezone" {
  type    = string
  default = "Europe/Oslo"
}