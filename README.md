# iam-user-automation-terraform
Project 4: IAM User Automation with Terraform

Creates an IAM user with an inline S3 read-only policy. By default, the policy
allows S3 `Get`, `List`, and `Describe` actions on all resources; it does not
grant write access. Override `s3_read_policy` with a JSON IAM policy to restrict
access to specific resources or otherwise change the permissions. The default
region is `ap-south-1`, and the default user name is `s3-read-user`.

## Deploy

Install Terraform 1.7 or later and configure AWS credentials with permission to
create IAM users and manage inline user policies. Then run:

```sh
terraform init
terraform plan
terraform apply
```

Set `aws_region`, `iam_user_name`, or `s3_read_policy` using Terraform variables
when the defaults are not appropriate. IAM is a global service; the region
configures the AWS provider.

## Verify permissions

Run the configuration tests without creating AWS resources:

```sh
terraform test
```

After applying the default policy, use AWS CLI credentials authorized to call
`iam:SimulatePrincipalPolicy`. Replace the bucket and object names below with
the resources you want to check:

```sh
USER_ARN="$(terraform output -raw iam_user_arn)"
aws iam simulate-principal-policy --policy-source-arn "$USER_ARN" \
  --action-names s3:ListBucket --resource-arns arn:aws:s3:::example-bucket \
  --query 'EvaluationResults[*].[EvalActionName,EvalDecision]' --output table
aws iam simulate-principal-policy --policy-source-arn "$USER_ARN" \
  --action-names s3:GetObject s3:PutObject --resource-arns arn:aws:s3:::example-bucket/example-object \
  --query 'EvaluationResults[*].[EvalActionName,EvalDecision]' --output table
```

The default policy should report `allowed` for `ListBucket` and `GetObject`, and
`implicitDeny` for `PutObject`. The simulator checks identity policies, not all
conditions of a real S3 request; bucket policies, organization policies, and
other controls can affect actual access. A custom policy may produce different
results.
