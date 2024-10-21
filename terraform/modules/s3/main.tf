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


######
resource "null_resource" "playbook_trigger" {
  triggers = {
    file_md5 = filemd5("${path.root}/files/ansible/initial_playbook.yml")
  }
}

resource "aws_s3_object" "initial_config_playbook" {
  bucket = aws_s3_bucket.config_bucket.bucket
  key    = "initial_config/initial_playbook.yml"
  content = templatefile("${path.root}/files/ansible/initial_playbook.yml", {
    pca_arn              = var.pca_arn,
    region               = var.region,
    locality                 = var.pca.subject.locality,
    country              = var.pca.subject.country,
    state                = var.pca.subject.state,
    organization         = var.pca.subject.organization,
    organizational_unit  = var.pca.subject.organizational_unit,
    common_name          = var.pca.subject.common_name
  })
  acl    = "private"

  tags = var.tags

  depends_on = [null_resource.playbook_trigger]
}



######
resource "null_resource" "playbook_requirements_trigger" {
  triggers = {
    file_md5 = filemd5("${path.root}/files/ansible/requirements.yml")
  }
}

resource "aws_s3_object" "playbook_requirements" {
  bucket = aws_s3_bucket.config_bucket.bucket
  key    = "initial_config/requirements.yml"
  source = "${path.root}/files/ansible/requirements.yml"
  acl    = "private"

  tags = var.tags

  depends_on = [null_resource.playbook_requirements_trigger]
}

#######
resource "null_resource" "script_trigger" {
  triggers = {
    file_md5 = filemd5("${path.root}/files/ansible/execute_ansible.sh")
  }
}

resource "aws_s3_object" "execute_playbook_script" {
  bucket = aws_s3_bucket.config_bucket.bucket
  key    = "initial_config/execute_ansible.sh"
  source = "${path.root}/files/ansible/execute_ansible.sh"
  acl    = "private"

  tags = var.tags

  depends_on = [null_resource.script_trigger]
}

