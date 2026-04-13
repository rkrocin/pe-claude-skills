# IaC Compliance Reviewer

A [Claude Skill](https://docs.anthropic.com/) that evaluates Terraform and CloudFormation templates against security, regulatory, and cost governance policy sets, producing audit-ready compliance reports with remediation guidance.

## What It Does

Feed it an infrastructure-as-code template and it generates:

- **Compliance Summary** with pass/fail counts by severity
- **Findings** referencing specific resources, violated controls, and risk context
- **Remediation** with corrected code snippets
- **Audit Narrative** suitable for regulatory documentation or leadership reporting

## Policy Frameworks

| Framework | Controls | Focus |
|-----------|----------|-------|
| General Cloud Security | 16 controls | Encryption, access control, networking, logging, secrets management |
| PCI DSS | 14 controls | Cardholder data environment requirements (v4.0 infrastructure layer) |
| FinOps | 12 controls | Cost allocation tagging, rightsizing, lifecycle management, spend governance |

Frameworks can be combined in a single review. Overlapping controls use the stricter severity.

## Usage

### With Claude Desktop or Claude.ai

Install the skill, then provide your IaC template:

```
Review this Terraform configuration for PCI DSS and general security compliance:

[paste your .tf file contents]
```

Or specify a framework:

```
Run a FinOps review on this CloudFormation template to find cost optimization opportunities.
```

### Audience

The skill produces two layers of output: detailed findings for engineering teams and an audit narrative for leadership. The findings include corrected code snippets engineers can apply directly. The narrative frames results in terms of risk posture rather than failure counts.

## Sample Templates

The `assets/` directory contains templates for testing:

| File | Description |
|------|-------------|
| `sample-noncompliant.tf` | Deliberately non-compliant Terraform with 15+ violations across all frameworks |
| `sample-compliant.tf` | Well-architected Terraform demonstrating best practices for a PCI CDE |
| `sample-cloudformation.json` | Mixed-compliance CloudFormation with both passing and failing resources |

### Quick Demo

Try running the non-compliant sample through the skill. It contains a payments infrastructure with hardcoded database passwords, SSH open to the internet, wildcard IAM policies, unencrypted data stores, previous-generation instances, and missing tags. The compliance report will surface all of these with specific remediation steps.

## Control Highlights

### Security Controls
- S3 encryption, public access blocks, and access logging
- RDS encryption at rest and in transit, public accessibility checks
- IAM least-privilege evaluation (wildcard action/resource detection)
- Security group ingress restrictions (SSH/RDP exposure)
- Hardcoded secrets detection
- KMS key rotation enforcement

### PCI DSS Controls
- CDE network segmentation validation
- Customer-managed KMS key requirements (not AWS-managed)
- TLS 1.2+ enforcement on load balancers and databases
- CloudTrail with log file validation
- VPC flow logs for CDE networks
- CDE-specific tagging for scope identification

### FinOps Controls
- Cost allocation tag enforcement (CostCenter, Application, Environment)
- Previous-generation instance type detection (m4/c4/r4 families)
- GP2 to GP3 EBS volume migration opportunities
- S3 lifecycle policy presence
- Multi-AZ and NAT gateway cost awareness for non-production
- CloudWatch log retention enforcement

## Skill Structure

```
iac-compliance-reviewer/
├── SKILL.md                         # Skill definition and review process
├── README.md                        # This file
├── references/
│   ├── general-security.md          # 16 baseline security controls
│   ├── pci-dss.md                   # 14 PCI DSS infrastructure controls
│   └── finops.md                    # 12 cost governance controls
└── assets/
    ├── sample-noncompliant.tf       # Terraform with multiple violations
    ├── sample-compliant.tf          # Terraform following best practices
    └── sample-cloudformation.json   # CloudFormation with mixed compliance
```

## Design Decisions

**Why not use a linter like tfsec or checkov?** Those tools are excellent for CI/CD pipelines. This skill serves a different purpose: it generates human-readable compliance narratives with business context, risk framing, and remediation guidance that can go directly into audit documentation or leadership reports. It complements automated scanning rather than replacing it.

**Why structured policy files instead of free-form prompts?** Structured controls with IDs, severity levels, and specific check criteria produce consistent, reproducible findings. Free-form "check this for security issues" prompts generate variable results. The policy files act as a contract between the skill and the reviewer.

**Why three frameworks instead of one big list?** Different reviews serve different stakeholders. A FinOps review for a cost optimization sprint should not bury findings in PCI controls. Separating frameworks lets the reviewer (and the reader) focus on what matters for their context.

## License

MIT
