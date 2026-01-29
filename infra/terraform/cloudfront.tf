# AWS CloudFront Distribution for CloudOps Status Page

# I will include Origin Access Control (OAC) to signs requests to S3 with SigV4.
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-cloudops-status-page"
  description                       = "OAC for S3 origin"
  origin_access_control_origin_type = "s3"
  signing_protocol                  = "sigv4"
  signing_behavior                  = "always"
}
/* Bucket policy that keeps account principals able to completely manage the bucket.
    Allows GET requests from my whitelisted IP address.
    Allows CloudFront (service principal) to GetObject so the OAC-signed requests succeed.
*/
data "aws_iam_policy_document" "s3_cloudfront_policy" {
  statement {
    sid    = "AllowAccountFullAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.cloudops_status_page_bucket.arn,
    "${aws_s3_bucket.cloudops_status_page_bucket.arn}/*"]
  }

  statement {
    sid    = "AllowGetObjectFromOwnerIP"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cloudops_status_page_bucket.arn}/*"]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = [var.owner_ip_cidr]
    }
  }

  statement {
    sid    = "AllowCloudFrontServicesGetObject"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cloudops_status_page_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = aws_s3_bucket.cloudops_status_page_bucket.id
  policy = data.aws_iam_policy_document.s3_cloudfront_policy.json
}

# I create a CloudFront distribution now with the S3 REST origin && the OAC above.
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  comment             = "CloudFront distribution for CloudOps status page"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.cloudops_status_page_bucket.bucket_regional_domain_name
    origin_id                = "S3-cloudops-status-page"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

  }

  default_cache_behavior {
    target_origin_id       = "S3-cloudops-status-page"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    compress    = true
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  # Unsure if I will be using a custom domain or using a subdomain under my current AWS hosted zone. For now, I will use the default CloudFront domain.
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Tags to help identify resources and track costs.
  tags = {
    Project     = "cloudops-status-page"
    Environment = var.environment
  }
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.cdn.id
}




