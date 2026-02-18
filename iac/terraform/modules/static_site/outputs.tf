output "bucket_name" {
  value       = aws_s3_bucket.website.bucket
  description = "Name of the S3 bucket holding the static site"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.website_cdn.domain_name
  description = "CloudFront distribution domain name"
}
