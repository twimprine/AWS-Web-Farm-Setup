
# Get Account ID for IAM policies
data "aws_caller_identity" "current" {}

# Give autoscaling EC2 instance ability to get the initial config scripts and such

# Removed condition for troubleshooting conditional tags
resource "aws_iam_role" "ec2_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  
  name = format("EC2_Combined_Role_%s", var.tags["project_name"])
  
  tags = merge(var.tags, {
    Name = format("EC2_Combined_Role_%s", var.tags["project_name"])
  })
}


# Create IAM role for EC2 instances - Commented out for troubleshooting conditional tags
# resource "aws_iam_role" "ec2_role" {
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Action = "sts:AssumeRole",
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       },
#       Condition = {
#         "StringEquals": {
#           "aws:RequestTag/project_name": var.tags["project_name"]
#         }
#       }
#     }]
#   })
  
#   name = format("EC2_Combined_Role_%s", var.tags["project_name"])
  
#   tags = merge(var.tags, {
#     Name = format("EC2_Combined_Role_%s", var.tags["project_name"])
#   })
# }





# # Create IAM role for EC2 instances
# resource "aws_iam_role" "ec2_combined_role" {
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
#   tags = merge(var.tags, {
#     Name = format("EC2_Combined_Role_%s", var.tags["project_name"])
#   })
# }

resource "aws_iam_policy" "s3_read_access" {
  description = "IAM policy for EC2 instances to read initial configuration files from S3"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # Grant access to list the bucket (required for ListBucket action)
        Action   = "s3:ListBucket",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.config_bucket_name}"
      },
      {
        # Grant access to the specific folder or objects in the bucket
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.config_bucket_name}/initial_config/*"
      }
    ]
  })
  name   = format("S3ReadAccess_%s", var.tags["project_name"]) 
  tags = merge(var.tags, {
    Name   = format("S3ReadAccess_%s", var.tags["project_name"]) 
  })
}




# Create the ACM PCA policy to allow EC2 to retrieve and export certificates
resource "aws_iam_policy" "ec2_acm_certificate_policy" {
  description = "Allows EC2 instances to retrieve and export ACM Private CA certificates"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
      "Action": [
				"acm:ExportCertificate",
				"acm:GetCertificate",
				"acm:RenewCertificate"
			],
        Resource = var.private_ca_arn
        Condition = {
          "StringEquals" = {
            "aws:RequestTag/PrivateCert" = "True",
            "aws:RequestTag/ProjectName" = var.tags["project_name"]
          }
        }
      }
    ]
  })
  name = format("EC2_ACM_Certificate_Policy_%s", var.tags["project_name"])
  tags = merge(var.tags, {
    Name = format("EC2_ACM_Certificate_Policy_%s", var.tags["project_name"])
  })
}

# Create CloudWatch policy to allow EC2 to write logs and send metrics to CloudWatch
resource "aws_iam_policy" "cloudwatch_policy" {
  description = "IAM policy for EC2 instances to download agent and write logs and metrics to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
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
      },
      {
        Effect: "Allow",
        Action: [
          "ssm:DescribeInstanceInformation",
          "ssm:GetParameter",
          "ssm:ListCommands",
          "ssm:SendCommand",
          "ssm:StartSession"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "ssmmessages:SendHeartbeat"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "s3:GetObject"
        ],
        Resource: "arn:aws:s3:::amazoncloudwatch-agent/*"
      }
    ]
  })

  name = format("EC2_CloudWatch_Policy_%s", var.tags["project_name"])
  tags = merge(var.tags, {
    Name = format("EC2_CloudWatch_Policy_%s", var.tags["project_name"])
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

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_access.arn
}

# Create instance profile for EC2 instances
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = format("EC2_Instance_Profile_%s", var.tags["project_name"])
  role = aws_iam_role.ec2_role.name
}


