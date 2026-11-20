terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_user" "s3_reader" {
  name = var.iam_user_name
}

resource "aws_iam_user_policy" "s3_read" {
  name   = "s3-read"
  user   = aws_iam_user.s3_reader.name
  policy = var.s3_read_policy
}

output "iam_user_arn" {
  description = "ARN of the IAM user."
  value       = aws_iam_user.s3_reader.arn
}
