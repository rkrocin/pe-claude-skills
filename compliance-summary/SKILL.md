---
name: iac-compliance-reviewer
description: >
  Review Infrastructure-as-Code templates (Terraform HCL, CloudFormation JSON/YAML) for compliance
  against security, regulatory, and operational policy sets. Use this skill whenever the user provides
  IaC templates, Terraform files, CloudFormation templates, or infrastructure definitions and wants a
  compliance review, security assessment, policy check, audit readiness evaluation, or remediation
  guidance. Also trigger when the user asks about IaC best practices for regulated environments,
  tagging standards, encryption requirements, or least-privilege IAM patterns. Supports PCI DSS,
  general cloud security, and FinOps policy frameworks.
---

# IaC Compliance Reviewer

Evaluate Infrastructure-as-Code templates against configurable compliance policy sets and produce audit-ready findings with remediation guidance.

## What This Skill Does

Takes a Terraform (HCL) or CloudFormation (JSON/YAML) template and evaluates it against one or more policy frameworks. Produces:

1. **Compliance Summary** - Pass/fail count by severity, overall compliance posture
2. **Findings** - Each non-compliant resource with the violated control, severity, and explanation
3. **Remediation** - Corrected code snippets for each finding
4. **Audit Narrative** - A prose summary suitable for including in audit evidence or leadership reporting

## Supported Input Formats

| Format | Extension | Detection |
|--------|-----------|-----------|
| Terraform HCL | `.tf` | `resource`, `data`, `module`, `variable` blocks |
| CloudFormation JSON | `.json` | `AWSTemplateFormatVersion` or `Resources` top-level key |
| CloudFormation YAML | `.yaml` / `.yml` | `AWSTemplateFormatVersion` or `Resources` top-level key |

The skill parses resource definitions statically. It does not execute `terraform plan` or deploy anything.

## Policy Frameworks

Three policy sets are available in the `references/` directory. Load the relevant one(s) based on the user's request. If no framework is specified, default to `general-security.md`.

| Framework | File | Use When |
|-----------|------|----------|
| General Cloud Security | `references/general-security.md` | Default. Covers encryption, access control, networking, tagging |
| PCI DSS | `references/pci-dss.md` | User mentions PCI, payment card, cardholder data, or regulated financial workloads |
| FinOps | `references/finops.md` | User mentions cost optimization, tagging for billing, rightsizing, or budget governance |

Multiple frameworks can be applied in a single review. When combining, deduplicate overlapping controls and apply the stricter severity.

## Review Process

### Step 1: Parse the Template

Identify every resource block in the template. For each resource, note:
- Resource type (e.g., `aws_s3_bucket`, `AWS::S3::Bucket`)
- Resource name/logical ID
- All configured properties

### Step 2: Load Policy Controls

Read the appropriate policy reference file(s) from the `references/` directory. Each control includes:
- **Control ID**: Short identifier (e.g., `SEC-001`)
- **Title**: What the control checks
- **Applies To**: Which resource types this control evaluates
- **Check**: What to look for in the template
- **Severity**: Critical, High, Medium, or Low
- **Remediation**: How to fix a violation

### Step 3: Evaluate

For each resource, check all applicable controls. A control passes if the template explicitly satisfies the check. A control fails if the required configuration is missing or misconfigured.

Important evaluation principles:
- **Missing configuration is a finding.** If a control requires encryption and the template has no encryption block, that is a failure, not an unknown.
- **Default values are not compliant.** Do not assume AWS defaults satisfy a control unless the template explicitly sets the value.
- **Severity inheritance.** If a resource handles sensitive data (e.g., a database, a bucket with "pii" or "card" in the name), elevate findings by one severity level.

### Step 4: Generate Report

Follow this output structure:

```
## Compliance Summary

| Severity | Findings |
|----------|----------|
| Critical | N |
| High     | N |
| Medium   | N |
| Low      | N |

**Overall Posture**: [Compliant / Non-Compliant with N findings]
**Framework(s) Applied**: [list]

## Findings

### [SEVERITY] [CONTROL-ID]: [Title]
**Resource**: `resource_type.resource_name`
**Issue**: [What is missing or misconfigured]
**Risk**: [What could happen if this is not addressed]
**Remediation**:
[Corrected code snippet showing the fix in context]

[Repeat for each finding, ordered by severity descending]

## Compliant Resources

[List resources that passed all applicable controls - this provides positive audit evidence]

## Audit Narrative

[3-5 sentence prose summary of the review results, suitable for inclusion in audit
documentation or leadership reporting. Frame in terms of risk posture, not just
checkbox compliance.]
```

### Severity Definitions

- **Critical**: Direct exposure of sensitive data or credentials, unrestricted public access to data stores, no encryption on regulated data. Must remediate before deployment.
- **High**: Overly permissive IAM policies, missing access logging, unencrypted data at rest in non-regulated contexts. Remediate within current sprint.
- **Medium**: Missing tagging, non-optimal network configuration, absent lifecycle policies. Remediate within current quarter.
- **Low**: Style or convention deviations, informational best practices. Address as capacity allows.

## Edge Cases

- **Modules**: If the template references external modules, note that the module internals cannot be evaluated and recommend reviewing the module source separately.
- **Variables without defaults**: If a security-relevant property is set via variable with no default, flag it as "requires runtime verification" rather than a hard fail.
- **Data sources**: Data source blocks that reference existing infrastructure should not be evaluated as if they are resource definitions.
- **Multiple files**: If the user provides multiple `.tf` files, treat them as a single configuration and evaluate holistically.
- **Non-AWS providers**: The policy sets are AWS-focused. If the template targets another provider (Azure, GCP), note this and apply controls by analogy where applicable, but flag that the policy set may not cover provider-specific patterns.

## Tone and Framing

Write findings as a trusted advisor, not an auditor looking for gotchas. The goal is to help the team ship safely, not to generate a compliance report for its own sake. Frame remediation as "here is how to fix this" rather than "you failed to do this."

For leadership-facing audit narratives, emphasize risk posture and the proportion of infrastructure that meets policy, rather than leading with failure counts.
