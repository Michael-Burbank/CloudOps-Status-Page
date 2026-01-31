
# AWS S3 Bucket for CloudOps Status Page (Frontend Only)
#
# I use this Terraform configuration to provision a single S3 bucket dedicated to hosting only the static frontend assets (HTML, CSS, JS, images) for my status page. All backend/API/monitoring is handled by EC2.
#
# In development, I allow GETs from my whitelisted IP for direct S3 website access. In production, I plan to use CloudFront as the only public access, keeping the bucket private and allowing CloudFront (via OAI/OAC) to fetch objects.
#
# All other AWS principals in my account retain full access. I use SSE-S3 for server-side encryption so anonymous reads (from my whitelisted IP) can succeed if needed.

# Input variables ------------------------------------------------------------

variable "environment" {
  description = "Deployment environment identifier used to namespace resources (dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "owner_ip_cidr" {
  description = "Public IPv4 address in CIDR format that is allowed anonymous GET access to the S3 website. Required for my dev workflow."
  type        = string
}

# Data sources ---------------------------------------------------------------
# I retrieve the current account ID so the bucket policy can grant full access to account principals.
data "aws_caller_identity" "current" {}

# Helpers --------------------------------------------------------------------
# I generate a short random suffix so the bucket name is unlikely to collide globally.
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket ------------------------------------------------------------------
# I create the S3 bucket to host only the static frontend files for my status page. The name includes the environment and a short random suffix for uniqueness.
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
# I enforce the bucket owner ownership model (disables legacy ACL semantics).
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.cloudops_status_page_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public access blocking (tunable) ------------------------------------------
# I keep most public protections enabled but allow a bucket policy to exist.
# This permits a scoped policy (below) that grants GETs only from my whitelisted IP.
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.cloudops_status_page_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Server-side encryption ----------------------------------------------------
# I configure SSE-S3 (AES256) for objects so anonymous reads via the S3 website endpoint
# can succeed without KMS permissions. This keeps contents encrypted at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudops_status_page_bucket_encryption" {
  bucket = aws_s3_bucket.cloudops_status_page_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket policy: account principals + IP whitelist (dev) ---------------------
# - I grant full S3 permissions to my AWS account root (so I always have access).
# - In development, I allow anonymous s3:GetObject only from my whitelisted IP for direct S3 website testing.
# - In production, I will update this policy to allow only CloudFront (OAI/OAC) to access the bucket.
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
# I configure the bucket to serve index.html via the S3 website endpoint for development and testing. In production, I will use CloudFront as the public entry point for the static site.
resource "aws_s3_bucket_website_configuration" "cloudops_status_page_bucket_website" {
  bucket = aws_s3_bucket.cloudops_status_page_bucket.id

  index_document {
    suffix = "index.html"
  }

  # If I have a custom error page, I can uncomment the following block:
  # error_document {
  #   key = "error.html"
  # }
}

# Outputs --------------------------------------------------------------------
# I output the plaintext bucket name so I can use it in scripts or local testing to upload static frontend files.
output "s3_bucket_name" {
  description = "S3 bucket name for the status page (use this to upload static frontend files)."
  value       = aws_s3_bucket.cloudops_status_page_bucket.bucket
}

# ASIDE: I removed the KMS key output because I'm using SSE-S3 for the public-facing website.
