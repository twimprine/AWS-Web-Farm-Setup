# Create ACM PCA Root CA
resource "aws_acmpca_certificate_authority" "private_ca" {
  type = "ROOT"

  certificate_authority_configuration {
    key_algorithm     = var.key_algorithm
    signing_algorithm = var.signing_algorithm

    subject {
      common_name         = var.common_name
      organization        = var.organization
      organizational_unit = var.organizational_unit
      country             = var.country
      state               = var.state
      locality            = var.locality
    }
  }

  permanent_deletion_time_in_days = 7
  enabled                         = true

  tags = merge(var.tags, {
    Name = format("Private CA - %s", var.tags["project_name"])
  })
}

# Issue the root certificate for the CA
resource "aws_acmpca_certificate" "ca_certificate" {
  certificate_authority_arn   = aws_acmpca_certificate_authority.private_ca.arn
  certificate_signing_request = aws_acmpca_certificate_authority.private_ca.certificate_signing_request
  signing_algorithm           = "SHA512WITHRSA"

  # Specify the template ARN for a Root CA
  template_arn = "arn:aws:acm-pca:::template/RootCACertificate/V1"

  validity {
    type  = "YEARS"
    value = 10
  }
}

# Associate the issued certificate with the ACM PCA Certificate Authority
resource "aws_acmpca_certificate_authority_certificate" "private_ca_certificate" {
  certificate_authority_arn = aws_acmpca_certificate_authority.private_ca.arn
  certificate               = aws_acmpca_certificate.ca_certificate.certificate
  certificate_chain         = aws_acmpca_certificate.ca_certificate.certificate_chain
}

# Allow ACM to issue certificates
resource "aws_acmpca_permission" "acm_private_ca_permissions" {
  certificate_authority_arn = aws_acmpca_certificate_authority.private_ca.arn
  principal                 = "acm.amazonaws.com"

  actions = [
    "IssueCertificate",
    "GetCertificate",
    "ListPermissions"
  ]
}

# Data source to get the current AWS partition
data "aws_partition" "current" {}
