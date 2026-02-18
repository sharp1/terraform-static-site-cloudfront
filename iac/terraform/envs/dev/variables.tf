variable "region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile to use"
  default     = "marquis-admin"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name for this environment"
  default     = "marquis-nextjs-portfolio-dev-2026-02"
}

variable "environment" {
  type        = string
  description = "Environment tag value"
  default     = "dev"
}
