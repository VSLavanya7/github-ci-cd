terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    bucket         = "github-ci-cd-statefile"
    key            = "lab/network/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "wklab-tf-lock-ci-cd
"
    encrypt        = true
  }
}
