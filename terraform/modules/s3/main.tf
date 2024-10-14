resource "aws_s3_bucket" "config_bucket" {
    bucket = lower(format("s3-%s", var.tags["project_name"]))

    tags = var.tags

    force_destroy = true
}

resource "aws_s3_object" "initial_config_playbook" {
  bucket = aws_s3_bucket.config_bucket.bucket
  key    = "initial_config/initial_playbook.yml"
  source = "${path.root}/files/scripts/initial_playbook.tftpl"
  acl    = "private"

  tags = var.tags
}

