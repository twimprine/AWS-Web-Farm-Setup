output "config_bucket_name" {
    description = "Name of the ec2 config bucket"
    value = aws_s3_bucket.config_bucket.bucket
}

output "initial_config_playbook" {
    value = aws_s3_object.initial_config_playbook
}