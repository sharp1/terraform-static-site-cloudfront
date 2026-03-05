# modules/static_site/main.tf

#checkov:skip=CKV2_AWS_62: Event notifications not required for static site bucket in this baseline.
#checkov:skip=CKV_AWS_144: Cross-region replication not required for lab baseline; would be enabled in production DR design.

########################
# S3 bucket for website
########################

resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true # fine for a lab; in prod you might remove this

  tags = {
    Name        = "Next.js static site bucket"
    Environment = var.environment
    Project     = "terraform-static-site-cloudfront"
  }
}


resource "aws_s3_bucket" "cf_logs" {
  bucket        = "${var.bucket_name}-cf-logs"
  force_destroy = true

  tags = {
    Name        = "CloudFront logs bucket"
    Environment = var.environment
    Project     = "terraform-static-site-cloudfront"
  }
}

########################
# 
########################

resource "aws_s3_bucket_public_access_block" "cf_logs" {
  bucket = aws_s3_bucket.cf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cf_logs" {
  bucket = aws_s3_bucket.cf_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

########################
# Versioning
########################

resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
########################
# Server-side encryption
########################

resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3, AWS-managed keys
    }
  }
}

########################
# Block public access
########################

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################
# Origin Access Identity
########################

resource "aws_cloudfront_origin_access_identity" "website_oai" {
  comment = "OAI for static website CloudFront distribution"
}

########################
# Bucket policy (OAI only)
########################

resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowOAIRead"
        Effect = "Allow"
        Principal = {
          CanonicalUser = aws_cloudfront_origin_access_identity.website_oai.s3_canonical_user_id
        }
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

########################
#            
########################

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "static-site-security-headers-${var.environment}"

  security_headers_config {
    content_type_options { override = true }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }

    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    xss_protection {
      protection = true
      mode_block = true
      override   = true
    }
  }
}


#checkov:skip=CKV_AWS_310: Lab uses a single S3 origin; origin failover not required for this baseline.
#checkov:skip=CKV_AWS_374: Geo restriction is a business requirement decision; not enabled in this baseline.
#checkov:skip=CKV2_AWS_42: No custom domain/ACM cert provisioned for this lab; default CloudFront certificate is acceptable.
#checkov:skip=CKV2_AWS_47: WAF is not included in the baseline lab; added during hardening phase.

########################
# CloudFront distribution
########################

resource "aws_cloudfront_distribution" "website_cdn" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "s3-website-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Static Next.js site behind CloudFront"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id           = "s3-website-origin"
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # For a real app you might tune this; 100 = only some regions, cheaper
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = {
    Project     = "terraform-static-site-cloudfront"
    Environment = var.environment
  }
}
