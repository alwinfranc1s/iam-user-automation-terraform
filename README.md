# iam-user-automation-terraform
Project 4: IAM User Automation with Terraform

Creates an IAM user with an inline S3 read-only policy, plus a sample S3 bucket
and text object for verification. By default, the policy
allows S3 `Get`, `List`, and `Describe` actions on all resources; it does not
grant write access. Override `s3_read_policy` with a JSON IAM policy to restrict
access to specific resources or otherwise change the permissions. The default
region is `ap-south-1`.

## Deploy

Install Terraform 1.7 or later and the AWS CLI, then configure AWS credentials
with permission to check IAM users (`iam:GetUser`), create IAM users, and manage
inline user policies, as well as create, read, and delete S3 buckets and
objects. Initialize Terraform and run the interactive deploy script:

```sh
terraform init
./deploy.sh
```

The script asks for a username, checks whether it already exists, and asks
again if it does. It then runs `terraform apply` with the available username.
The availability check cannot prevent another actor from creating that name
before Terraform applies it. IAM is a global service; `aws_region` configures
the AWS provider. Set `aws_region` or `s3_read_policy` using Terraform variables
when the defaults are not appropriate. Remember the username and any variable
overrides for cleanup.

## Verify permissions

Run the configuration tests without creating AWS resources:

```sh
terraform test
```

After applying the default policy, use AWS CLI credentials authorized to call
`iam:SimulatePrincipalPolicy`. The Terraform outputs identify the sample bucket
and object:

```sh
USER_ARN="$(terraform output -raw iam_user_arn)"
BUCKET_ARN="$(terraform output -raw sample_bucket_arn)"
OBJECT_ARN="$(terraform output -raw sample_object_arn)"
aws iam simulate-principal-policy --policy-source-arn "$USER_ARN" \
  --action-names s3:ListBucket --resource-arns "$BUCKET_ARN" \
  --query 'EvaluationResults[*].[EvalActionName,EvalDecision]' --output table
aws iam simulate-principal-policy --policy-source-arn "$USER_ARN" \
  --action-names s3:GetObject s3:PutObject --resource-arns "$OBJECT_ARN" \
  --query 'EvaluationResults[*].[EvalActionName,EvalDecision]' --output table
```

The default policy should report `allowed` for `ListBucket` and `GetObject`, and
`implicitDeny` for `PutObject`. The simulator checks identity policies, not all
conditions of a real S3 request; bucket policies, organization policies, and
other controls can affect actual access. A custom policy may produce different
results.

## Cleanup

From the same directory and Terraform state used for deployment, run:

```sh
terraform destroy -var="iam_user_name=YOUR_USERNAME"
```

Use the username entered during deployment and the same variable overrides,
particularly `aws_region`. Confirm the destroy plan to delete the Terraform-managed
IAM user, inline policy, sample object, and bucket. Terraform only deletes the
sample object it manages; remove any additional objects and object versions
from the bucket first or bucket deletion will fail. Preserve the state file until
the destroy completes.
