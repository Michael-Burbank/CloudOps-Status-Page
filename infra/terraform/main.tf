/*
Terraform configuration for the CloudOps Status Page infrastructure.
In this file, I provision a single S3 bucket for a private dev website/environment, with a
minimal public surface.

Only GETs from my whitelisted IP are allowed.
All other AWS principals in the account retain full access. Server-side
encryption uses SSE-S3 so anonymous reads (from the whitelisted IP) can succeed.
*/

# Input variables ------------------------------------------------------------
variable "aws_region" {
  description = "AWS region for this deployment"
  type        = string
  default     = "us-west-1"
}

variable "environment" {
  description = "Deployment environment identifier used to namespace resources (dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "owner_ip_cidr" {
  description = "Public IPv4 address in CIDR format that is allowed anonymous GET access to the S3 website. Required for dev workflow."
  type        = string
}

# Provider configuration -----------------------------------------------------
# Applies default tags to supported resources in this configuration.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "cloudops-status-page"
      Environment = var.environment
      Owner       = "mike"
    }
  }
}

# Data sources ---------------------------------------------------------------
# Get current account id so the bucket policy can grant full access to account principals.
data "aws_caller_identity" "current" {}

# Helpers --------------------------------------------------------------------
# Generate a short random suffix so the bucket name is unlikely to collide globally.
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket ------------------------------------------------------------------
# Primary S3 bucket to host the static status page files. Name includes environment + short random suffix.
resource "aws_s3_bucket" "cloudops_status_page_bucket" {
  bucket = "cloudops-status-page-${var.environment}-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "cloudops-status-page-${var.environment}"
    Project     = "cloudops-status-page"
    Environment = var.environment
    Owner       = "mike"
  }
}

# Ownership controls --------------------------------------------------------
# Enforce bucket owner ownership model (disables legacy ACL semantics).
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.cloudops_status_page_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public access blocking (tunable) ------------------------------------------
# Keep most public protections enabled but allow a public bucket policy to exist.
# This permits a scoped policy (below) that grants GETs only from the whitelisted IP.
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.cloudops_status_page_bucket.id

  block_public_acls       = true  # still ignore ACLs
  block_public_policy     = false # allow a bucket policy to explicitly permit access (scoped by IP)
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Server-side encryption ----------------------------------------------------
# Use SSE-S3 (AES256) for objects so anonymous reads via the S3 website endpoint
# can succeed without KMS permissions. This keeps contents encrypted at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudops_status_page_bucket_encryption" {
  bucket = aws_s3_bucket.cloudops_status_page_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket policy: account principals + IP whitelist ---------------------------
# - Grant full S3 permissions to the AWS account root (and therefore account principals).
# - Allow anonymous s3:GetObject only when the request originates from owner_ip_cidr.
data "aws_iam_policy_document" "s3_owner_and_ip_policy" {
  statement {
    sid    = "AllowAccountFullAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.cloudops_status_page_bucket.arn,
      "${aws_s3_bucket.cloudops_status_page_bucket.arn}/*"
    ]
  }

  statement {
    sid    = "AllowGetObjectFromOwnerIP"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.cloudops_status_page_bucket.arn}/*"
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = [var.owner_ip_cidr]
    }
  }
}

resource "aws_s3_bucket_policy" "owner_ip_policy" {
  bucket = aws_s3_bucket.cloudops_status_page_bucket.id
  policy = data.aws_iam_policy_document.s3_owner_and_ip_policy.json
}

# Static website hosting configuration --------------------------------------
# Configure the bucket to serve index.html via the S3 website endpoint.
resource "aws_s3_bucket_website_configuration" "cloudops_status_page_bucket_website" {
  bucket = aws_s3_bucket.cloudops_status_page_bucket.id

  index_document {
    suffix = "index.html"
  }

  # Optional: add error_document block if you have a custom error page:
  # error_document {
  #   key = "error.html"
  # }
}

# Outputs --------------------------------------------------------------------
# Plaintext bucket name for use in scripts / local testing.
output "s3_bucket_name" {
  description = "S3 bucket name for the status page (use this to upload files)."
  value       = aws_s3_bucket.cloudops_status_page_bucket.bucket
}

# ASIDE: KMS key output removed because SSE-KMS is not used for the public-facing website.
