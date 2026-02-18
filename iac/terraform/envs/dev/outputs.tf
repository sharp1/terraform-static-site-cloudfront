output "website_bucket_name" {
  value       = module.static_site.bucket_name
  description = "Website S3 bucket name for this environment"
}

output "cloudfront_domain_name" {
  value       = module.static_site.cloudfront_domain_name
  description = "CloudFront domain for this environment"
}
