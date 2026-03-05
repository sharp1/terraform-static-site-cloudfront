# Incident Response Notes (Cloud DevSecOps)

## Detection signals (examples)
- CloudTrail: unusual IAM activity (new access keys, policy changes)
- GuardDuty: credential compromise, unusual API calls
- VPC Flow Logs: unexpected egress patterns
- WAF/ALB logs (if applicable): spikes, exploit patterns
- Config/Security Hub (if enabled): drift & misconfig findings

## First actions (real-time response)
1) Triage: confirm alert scope + affected resources/accounts
2) Contain: disable keys, isolate SG rules, restrict egress, quarantine instances
3) Preserve evidence: snapshot logs, export CloudTrail/GuardDuty findings
4) Eradicate: remove malicious persistence, revert IAM/policy changes
5) Recover: restore known-good config, monitor for recurrence

## Audit/Compliance evidence you can produce
- Ticket/incident timeline
- CloudTrail event extracts (who/what/when)
- Before/after configuration diffs (IaC + change history)
- Vulnerability validation results (e.g., Nessus/ACAS evidence)
- Control mapping notes (NIST 800-53 / organizational standards)
