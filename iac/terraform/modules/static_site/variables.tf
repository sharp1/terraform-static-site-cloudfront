variable "bucket_name" {
  type        = string
  description = "S3 bucket name for the website"
}

variable "environment" {
  type        = string
  description = "Environment tag (dev/stage/prod)"
}
