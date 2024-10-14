
# Give autoscaling EC2 instance ability to get the initial config scripts and such

resource "aws_iam_role" "ec2_role" {
  name               = "webfarm_ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Condition = {
        StringEquals = {
          "aws:RequestTag/project_name": "${var.config_bucket_name}"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "s3_read_access" {
  name   = "S3ReadAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject"]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::${var.config_bucket_name}/initial_config/*"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_access.arn
}
