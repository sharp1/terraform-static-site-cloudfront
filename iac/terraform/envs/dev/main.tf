# envs/dev/main.tf

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}


module "static_site" {
  source      = "../../modules/static_site"
  bucket_name = var.bucket_name
  environment = var.environment
}
