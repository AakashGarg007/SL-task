# -- provider.tf (Provider) -- #

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    encrypt = true
    bucket  = "tf-rem-state"
    region  = "us-east-1"
    key     = "sl-task"
  }
}


provider "aws" {
  region = var.aws_region
}

