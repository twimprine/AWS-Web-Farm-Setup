output "ec2_acm_iam_profile_name" {
    description = "IAM Instance Profile for EC2 instances to access the ACM Private Certificate Authority"
    value = aws_iam_instance_profile.ec2_acm_instance_profile.name
}