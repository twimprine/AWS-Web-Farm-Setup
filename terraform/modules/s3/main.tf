resource "aws_s3_bucket" "config_bucket" {
    bucket = lower(format("s3-%s", var.tags["project_name"]))

    tags = var.tags
}

resource "aws_s3_bucket_versioning" "enable_versioning" {
  bucket = aws_s3_bucket.config_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "initial_config_playbook" {
  bucket = aws_s3_bucket.config_bucket.bucket
  key    = "initial_config/initial_playbook.yml"
  source = "${path.root}/files/ansible/initial_playbook.yml"
  acl    = "private"

  tags = var.tags
}

resource "aws_s3_object" "playbook_requirements" {
  bucket = aws_s3_bucket.config_bucket.bucket
  key    = "initial_config/requirements.yml"
  source = "${path.root}/files/ansible/requirements.yml"
  acl    = "private"

  tags = var.tags
}

resource "aws_s3_object" "execute_playbook_script" {
  bucket = aws_s3_bucket.config_bucket.bucket
  key    = "initial_config/execute_ansible.sh"
  source = "${path.root}/files/ansible/execute_ansible.sh"
  acl    = "private"

  tags = var.tags
}

