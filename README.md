# iam-user-automation-terraform
Project 4: IAM User Automation with Terraform

Creates an IAM user with an inline S3 read-only policy. By default, the policy
allows S3 `Get`, `List`, and `Describe` actions on all resources; it does not
grant write access. Override `s3_read_policy` with a JSON IAM policy to restrict
access to specific resources or otherwise change the permissions. The default
region is `ap-south-1`.

## Deploy

Install Terraform 1.7 or later and the AWS CLI, then configure AWS credentials
with permission to check IAM users (`iam:GetUser`), create IAM users, and manage
inline user policies. Initialize Terraform and run the interactive deploy
script:

```sh
terraform init
./deploy.sh
```

The script asks for a username, checks whether it already exists, and asks
again if it does. It then runs `terraform apply` with the available username.
The availability check cannot prevent another actor from creating that name
before Terraform applies it. IAM is a global service; `aws_region` configures
the AWS provider. Set `aws_region` or `s3_read_policy` using Terraform variables
when the defaults are not appropriate.

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
