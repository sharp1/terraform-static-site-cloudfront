# DevSecOps Security Integration (IaC)

## Goal
Prevent insecure infrastructure changes from reaching main by enforcing security gates in CI.

## CI Gates (GitHub Actions)
This repo enforces the following checks on PRs and main:
- terraform fmt -check (style consistency)
- terraform validate (syntax and internal consistency)
- tflint (best practices / AWS ruleset)
- checkov (IaC security scanning)

## What fails the build (examples)
Examples of guardrails:
- Public S3 access (public ACLs / public bucket policy)
- Overly permissive security groups (0.0.0.0/0 on admin ports)
- Wildcard IAM permissions (Action:* or Resource:* without constraints)
- Missing encryption-at-rest where applicable

## How this maps to GitLab CI / Jenkins
The same gates can run in GitLab/Jenkins by executing:
- terraform fmt -check -recursive
- terraform init -backend=false
- terraform validate
- tflint --init && tflint
- checkov -d .

## Future enhancements
- Add tfsec as an additional scanner
- Add unit tests for policy-as-code (OPA/Conftest)
- Add release pipeline for versioned deployments
