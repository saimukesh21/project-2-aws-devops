terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
variable "aws_region" {
  description = "AWS region for the project"
  type        = string
  default     = "ap-south-1"
}