# Terraform Static Site + CloudFront (Next.js)

Static website deployment using **Terraform** with a private S3 origin and CloudFront CDN, fronting a statically exported Next.js site.

## What this shows

- Terraform-managed infrastructure (repeatable, auditable, and modular)
- CDN (CloudFront) fronting a **private** S3 origin for global performance
- Clean separation of:
  - **App build** (Next.js → static export)
  - **Infrastructure** (S3, CloudFront, OAI)
- Environment-aware layout using Terraform **modules + envs**

---

## Architecture

High-level flow:

1. Next.js builds a static site (`npm run build` → `out/` folder).
2. A private S3 bucket stores the static assets.
3. A CloudFront distribution serves the content globally.
4. An Origin Access Identity (OAI) is the **only** principal allowed to read from the bucket.
5. Terraform defines and manages all of this as code.

![Architecture Diagram](docs/architecture/diagram.png)

---

## Repo layout

- `app/`  
  Next.js app source. `npm run build` emits a static export into `./out`.

- `iac/terraform/modules/static_site/`  
  Reusable Terraform module that creates:
  - S3 bucket (versioning + SSE-S3 encryption)
  - S3 public access block
  - CloudFront Origin Access Identity (OAI)
  - Bucket policy allowing **only** the OAI to read objects
  - CloudFront distribution in front of the bucket

- `iac/terraform/envs/dev/`  
  Environment-specific Terraform configuration that:
  - Configures the AWS provider (region, profile)
  - Calls the `static_site` module with:
    - `bucket_name`
    - `environment` tag
  - Exposes outputs:
    - `website_bucket_name`
    - `cloudfront_domain_name`

- `docs/architecture/`  
  Diagrams and notes for the deployment.

- `scripts/`  
  Optional helper scripts for build/deploy workflows.

---

## How to build and deploy

### 1. Build the Next.js app

From the repo root:

```bash
cd app
npm install        # first time
npm run build      # emits ./out


This produces a static export of the site under app/out/.

2. Deploy infrastructure (S3 + CloudFront + OAI)

From the repo root:

cd iac/terraform/envs/dev

terraform init     # first time in this env
terraform apply

Key outputs:

website_bucket_name – S3 bucket that will hold the static site

cloudfront_domain_name – CloudFront URL to access the site


3.Upload static site files S3

cd app

BUCKET=$(terraform -chdir=../iac/terraform/envs/dev output -raw website_bucket_name)

aws s3 sync ./out s3://$BUCKET --profile marquis-admin



4.Access the site via cloudfront
Get the cloudfront distribution domain

bash

terraform -chdir=../iac/terraform/envs/dev output cloudfront_domain_name

Open in browser:
https://<cloudfront_domain_name>

Notes

Terraform state can be stored locally or wired to a remote backend (S3 + DynamoDB) if needed.

AWS credentials are not stored in this repo. Use:

AWS CLI named profiles, or

Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, etc.).
