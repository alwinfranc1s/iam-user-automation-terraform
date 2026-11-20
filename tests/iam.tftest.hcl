mock_provider "aws" {}

run "default_s3_read_policy" {
  command = plan

  variables {
    iam_user_name = "s3-read-user"
  }

  assert {
    condition     = var.aws_region == "ap-south-1"
    error_message = "The default AWS region must be ap-south-1."
  }

  assert {
    condition     = aws_iam_user.s3_reader.name == "s3-read-user" && aws_iam_user_policy.s3_read.user == aws_iam_user.s3_reader.name
    error_message = "The S3 read policy must be attached to the IAM user."
  }

  assert {
    condition = (
      jsondecode(aws_iam_user_policy.s3_read.policy).Version == "2012-10-17" &&
      jsondecode(aws_iam_user_policy.s3_read.policy).Statement[0].Effect == "Allow" &&
      toset(jsondecode(aws_iam_user_policy.s3_read.policy).Statement[0].Action) == toset(["s3:Get*", "s3:List*", "s3:Describe*"]) &&
      jsondecode(aws_iam_user_policy.s3_read.policy).Statement[0].Resource == "*"
    )
    error_message = "The default policy must grant only S3 read actions."
  }
}

run "custom_policy" {
  command = plan

  variables {
    iam_user_name  = "s3-read-user"
    s3_read_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::example-bucket/*\"}]}"
  }

  assert {
    condition     = jsondecode(aws_iam_user_policy.s3_read.policy).Statement[0].Resource == "arn:aws:s3:::example-bucket/*"
    error_message = "The IAM user policy must use the supplied policy variable."
  }
}
