terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "github-ci-cd-statefile"
    key    = "production/terraform.tfstate"
    region = "**CHANGE_THIS_AWS_REGION**"
  }
}