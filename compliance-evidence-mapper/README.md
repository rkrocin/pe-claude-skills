# Compliance Evidence Mapper

A [Claude Skill](https://docs.anthropic.com/) that maps existing infrastructure controls to regulatory compliance framework requirements, identifies gaps, and generates audit-ready evidence matrices with remediation plans.

## What It Does

Provide your controls inventory (tools, configurations, policies in place) and specify which compliance framework(s) to map against. The skill generates:

- **Evidence Matrix** mapping each requirement to the control(s) that satisfy it
- **Gap Analysis** with prioritized remediation plans for unmet requirements
- **Cross-Framework Coverage** showing where one control satisfies multiple frameworks
- **Audit Narrative** summarizing compliance posture for auditor or leadership consumption

## Why

Audit preparation is one of the most time-consuming activities in regulated environments. Teams spend weeks manually mapping controls to requirements, chasing evidence across tools and repos, and documenting gaps. This skill automates the mapping and gap identification, letting teams focus on remediation rather than spreadsheet assembly.

The cross-framework view is particularly valuable for organizations that maintain multiple certifications. A single KMS encryption control might satisfy requirements in PCI DSS, SOC 2, NIST CSF, and CIS Benchmarks simultaneously. Seeing this overlap explicitly justifies security investment and reduces duplicated audit effort.

## Supported Frameworks

| Framework | Controls | Focus |
|-----------|----------|-------|
| PCI DSS v4.0 | 30 requirements | Payment card environments, cardholder data |
| SOC 2 Type II | 22 criteria | Trust services: security, availability, confidentiality, processing integrity, privacy |
| NIST CSF 2.0 | 28 subcategories | General cybersecurity framework across six functions |
| CIS AWS Foundations | 20 controls | AWS-specific security configuration baselines |

Frameworks can be mapped individually or combined for cross-framework analysis.

## Usage

### With Claude Desktop or Claude.ai

Install the skill, then provide your controls inventory:

```
We have KMS encryption on all S3 buckets and RDS instances. CloudTrail is 
enabled multi-region with log validation. IAM policies are managed through 
Terraform with quarterly access reviews. VPC flow logs are on in all CDE VPCs. 
We run Trivy scans in CI/CD and Qualys for external ASV scanning.

Map this against PCI DSS for our upcoming audit.
```

Or for multi-framework mapping:

```
Here's our controls inventory [paste JSON]. Map it against PCI DSS, SOC 2, 
and NIST CSF and show me the cross-framework coverage.
```

### Input Formats

The skill accepts controls in any format: structured JSON, bullet lists, or conversational descriptions. See `assets/sample-controls-inventory.json` for the structured format.

## Sample Outputs

| File | Description |
|------|-------------|
| `sample-controls-inventory.json` | Input: 30 controls across a CDE environment |
| `sample-pci-mapping.md` | Output: Full PCI DSS evidence matrix with gap analysis and audit narrative |
| `sample-cross-framework.md` | Output: Cross-framework coverage matrix across PCI, SOC 2, NIST, CIS |

### Key Metrics from Sample Output

The sample PCI mapping demonstrates a realistic compliance posture: 73% of requirements fully satisfied, 17% partially satisfied, and 7% gaps. The two gaps are documentation-oriented (unified IR plan, IDS documentation) rather than architectural, which is a common pattern in mature environments. The audit narrative frames this constructively for the auditor.

The cross-framework sample shows that 22 controls satisfy 80+ individual requirements across four frameworks, demonstrating efficient security investment.

## Mapping Principles

**Missing evidence is a gap.** A control without verifiable evidence is effectively non-existent from an auditor's perspective. The skill flags controls that lack documented evidence locations.

**Partial coverage is not compliance.** If encryption is required on all data stores and only S3 is encrypted, the requirement is partially satisfied, not satisfied.

**Process controls matter.** Some requirements cannot be met by technology alone. Access reviews, incident response procedures, and security awareness training are process controls that need documented evidence.

**Inherited controls are acknowledged.** Cloud provider controls (physical security, hypervisor isolation) are noted as inherited with references to the provider's compliance documentation.

## Skill Structure

```
compliance-evidence-mapper/
├── SKILL.md                           # Skill definition and mapping process
├── README.md                          # This file
├── references/
│   ├── pci-dss-v4.md                  # 30 PCI DSS infrastructure requirements
│   ├── soc2.md                        # 22 SOC 2 trust services criteria
│   ├── nist-csf.md                    # 28 NIST CSF subcategories
│   └── cis-aws.md                     # 20 CIS AWS Benchmark controls
└── assets/
    ├── sample-controls-inventory.json  # Example input: 30-control inventory
    ├── sample-pci-mapping.md           # Example output: PCI evidence matrix
    └── sample-cross-framework.md       # Example output: multi-framework coverage
```

## Relationship to IaC Compliance Reviewer

The [IaC Compliance Reviewer](../iac-compliance-reviewer) evaluates individual Terraform/CloudFormation templates against policy controls at the code level. This Compliance Evidence Mapper operates at a higher level: it maps an organization's entire controls inventory against regulatory frameworks for audit preparation. They complement each other. The IaC reviewer catches issues in individual templates before they reach production. The evidence mapper ensures the overall control environment satisfies regulatory requirements when the auditor arrives.

## License

MIT
