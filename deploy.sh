#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v aws >/dev/null 2>&1; then
  printf 'AWS CLI is required to check IAM username availability.\n' >&2
  exit 1
fi

while true; do
  read -r -p "Enter an IAM username: " username
  if [[ -z "$username" ]]; then
    printf 'Username cannot be empty. Try again.\n' >&2
    continue
  fi

  if error=$(aws iam get-user --user-name "$username" 2>&1 >/dev/null); then
    printf 'IAM username "%s" already exists. Try another username.\n' "$username"
  elif [[ "$error" == *"(NoSuchEntity)"* ]]; then
    break
  else
    printf 'Unable to check IAM username availability: %s\n' "$error" >&2
    exit 1
  fi
done

exec terraform apply -var="iam_user_name=$username"
