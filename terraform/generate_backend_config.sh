#!/bin/bash

# Check if jq is installed
if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed. Please install jq to proceed."
  exit 1
fi

# Read variables from terraform.tfvars.json
PROJECT_NAME=$(jq -r '.project_name' terraform.tfvars.json)
AWS_REGION=$(jq -r '.aws_region' terraform.tfvars.json)

# Validate that variables are not empty
if [ -z "$PROJECT_NAME" ] || [ -z ${AWS_REGION} ]; then
  echo "Error: project_name or aws_region is not set in terraform.tfvars.json."
  exit 1
fi

# Determine the branch name
if [ -n "$GITHUB_REF" ]; then
  BRANCH_NAME=${GITHUB_REF##*/}
else
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Handle errors if BRANCH_NAME is empty
if [ -z "$BRANCH_NAME" ]; then
  echo "Error: Could not determine the Git branch name."
  exit 1
fi

# Determine the project name based on the branch
PROJECT_NAME_LOWER=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
if [ "$BRANCH_NAME" = "main" ]; then
  PROJECT_NAME_FINAL="$PROJECT_NAME_LOWER"
else
  PROJECT_NAME_FINAL="${PROJECT_NAME_LOWER}-${BRANCH_NAME}"
fi

# Generate backend.conf
cat >backend.conf <<EOF
bucket         = "${PROJECT_NAME_FINAL}"
key            = "terraform.tfstate"
region         = "${AWS_REGION}"
dynamodb_table = "terraform-lock-table-${PROJECT_NAME_FINAL}"
encrypt        = true
EOF

echo "backend.conf generated successfully."

# Check if the S3 bucket exists
if aws s3api head-bucket --bucket ${PROJECT_NAME_FINAL} 2>/dev/null; then
  echo "S3 bucket $PROJECT_NAME_FINAL already exists."
else
  echo "Creating S3 bucket $PROJECT_NAME_FINAL..."
  aws s3api create-bucket --bucket "${PROJECT_NAME_FINAL}" --region ${AWS_REGION} 
  aws s3api put-bucket-versioning --bucket ${PROJECT_NAME_FINAL} --versioning-configuration Status=Enabled
  aws s3api put-bucket-encryption --bucket ${PROJECT_NAME_FINAL} --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
  echo "S3 bucket $PROJECT_NAME_FINAL created."
fi

# Check if the DynamoDB table exists
if aws dynamodb describe-table --table-name "terraform-lock-table-${PROJECT_NAME_FINAL}" 2>/dev/null; then
  echo "DynamoDB table terraform-lock-table-${PROJECT_NAME_FINAL} already exists."
else
  echo "Creating DynamoDB table terraform-lock-table-${PROJECT_NAME_FINAL}..."
  aws dynamodb create-table \
    --table-name "terraform-lock-table-${PROJECT_NAME_FINAL}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region ${AWS_REGION}
  echo "DynamoDB table terraform-lock-table-${PROJECT_NAME_FINAL} created."
fi

# Initialize Terraform
echo "Initializing Terraform..."
echo "Pausing 60 seconds to allow Bucket and DynamoDB table to be created..."
sleep 60
terraform init -backend-config=backend.conf
