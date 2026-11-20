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

resource "aws_s3_bucket" "sample" {
  bucket_prefix = "iam-user-automation-"
}

resource "aws_s3_object" "sample" {
  bucket       = aws_s3_bucket.sample.id
  key          = "example.txt"
  content      = "Example object for testing S3 read permissions.\n"
  content_type = "text/plain"
}

output "iam_user_arn" {
  description = "ARN of the IAM user."
  value       = aws_iam_user.s3_reader.arn
}

output "sample_bucket_arn" {
  description = "ARN of the sample S3 bucket."
  value       = aws_s3_bucket.sample.arn
}

output "sample_object_arn" {
  description = "ARN of the sample S3 object."
  value       = "${aws_s3_bucket.sample.arn}/${aws_s3_object.sample.key}"
}
