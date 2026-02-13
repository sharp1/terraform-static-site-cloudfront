# Terraform Static Site + CloudFront (Next.js)

Static website deployment using **Terraform** with an S3 origin and CloudFront CDN.

## What this shows
- Terraform-managed infrastructure (repeatable + auditable)
- CDN fronting an S3 origin for global performance
- Clean separation of app build vs infrastructure

## Architecture
![Architecture Diagram](docs/architecture/diagram.png)

## Repo layout
- `iac/terraform/` Terraform code
- `docs/architecture/` diagrams
- `scripts/` build/deploy helpers
- `app/` (optional) app source or build artifacts

## Typical workflow
1) Build the site
2) Deploy infra (S3/CloudFront)
3) Upload artifacts

> Note: keep AWS credentials out of git. Use AWS CLI profiles or env vars.

