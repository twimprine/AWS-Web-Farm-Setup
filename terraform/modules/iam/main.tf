
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


# Create IAM role for EC2 instances
resource "aws_iam_role" "ec2_combined_role" {
  name = "EC2_Combined_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, 
    { 
      Name = "EC2 Combined Role" 
    })
}

# Create the ACM PCA policy to allow EC2 to retrieve and export certificates
resource "aws_iam_policy" "ec2_acm_certificate_policy" {
  name        = "EC2_ACM_Certificate_Policy"
  description = "Allows EC2 instances to retrieve and export ACM Private CA certificates"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "acm-pca:ExportCertificate",
          "acm:GetCertificate"
        ],
        Resource = var.private_ca_arn
        Condition = {
          "ForAllValues:StringEquals" = {
            "aws:RequestTag/PrivateCert" = "True",
            "aws:RequestTag/ProjectName" = var.tags["project_name"]
          }
        }
      }
    ]
  })
}

# Create CloudWatch policy to allow EC2 to write logs and send metrics to CloudWatch
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "EC2CloudWatchPolicy"
  description = "IAM policy for EC2 instances to write logs and metrics to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "cloudwatch:PutMetricData"
        ],
        Resource: "*"
      }
    ]
  })
}

# Attach both the ACM PCA and CloudWatch policies to the combined role
resource "aws_iam_role_policy_attachment" "acm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_acm_certificate_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

# Create instance profile for EC2 instances
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2_Instance_Profile"
  role = aws_iam_role.ec2_role.name
}
