output "ec2_iam_profile_name" {
    description = "IAM Instance Profile for EC2 instances"
    value = aws_iam_instance_profile.ec2_instance_profile.name
}