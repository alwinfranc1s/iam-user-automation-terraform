variable "aws_region" {
  description = "AWS region used by the provider."
  type        = string
  default     = "ap-south-1"
}

variable "iam_user_name" {
  description = "Name of the IAM user to create."
  type        = string
}

variable "s3_read_policy" {
  description = "JSON IAM policy attached to the user."
  type        = string
  default     = <<-JSON
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["s3:Get*", "s3:List*", "s3:Describe*"],
          "Resource": "*"
        }
      ]
    }
  JSON
}
