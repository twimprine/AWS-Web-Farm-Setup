# provider configuration
provider "aws" {
  region = var.aws_region  # specify your desired region
}

# Create S3 bucket for Terraform state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.project_name
  tags = var.tags
  

  # Enable versioning so you can recover state files if needed
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion of the bucket
  }
}

# Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = lower(format("terraform-locks-%s", var.project_name))
  billing_mode = "PAY_PER_REQUEST"  # No need to worry about provisioning capacity
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}
