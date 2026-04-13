---
name: compliance-evidence-mapper
description: >
  Map existing infrastructure controls, tools, and configurations to regulatory compliance
  framework requirements and generate audit-ready evidence matrices. Use this skill whenever the
  user wants to prepare for a compliance audit, map controls to requirements, identify compliance
  gaps, generate evidence documentation, or build a controls inventory against PCI DSS, SOC 2,
  NIST CSF, or CIS Benchmarks. Also trigger when the user mentions audit preparation, evidence
  collection, control mapping, compliance gaps, remediation planning, or regulatory readiness
  assessment. Supports multi-framework mapping where a single control satisfies requirements
  across multiple standards.
---

# Compliance Evidence Mapper

Map existing infrastructure controls, tools, and configurations to regulatory compliance framework requirements. Identify gaps, generate evidence matrices, and produce audit-ready documentation.

## What This Skill Does

Takes an inventory of existing controls (tools, configurations, policies, processes) and maps them against one or more compliance frameworks. Produces:

1. **Evidence Matrix** mapping each framework requirement to the control(s) that satisfy it, with evidence references
2. **Gap Analysis** identifying requirements with no mapped control or insufficient evidence
3. **Cross-Framework Coverage** showing where a single control satisfies multiple framework requirements
4. **Remediation Plan** for identified gaps, prioritized by risk and effort
5. **Audit Narrative** summarizing the organization's compliance posture for auditor or leadership consumption

## Input Format

The user provides a controls inventory describing what is currently in place. Accept this in any format: structured JSON, bullet list, prose description, or conversational. The skill normalizes it into a structured inventory for mapping.

### Controls Inventory Structure

Each control should capture:

| Field | Required | Description |
|-------|----------|-------------|
| Control name | Yes | What the control is (e.g., "S3 encryption at rest via KMS") |
| Category | Helpful | Grouping (e.g., encryption, access control, logging) |
| Tool/service | Helpful | Implementation technology (e.g., AWS KMS, CloudTrail, Terraform) |
| Evidence location | Optional | Where the evidence can be found (e.g., "Terraform repo", "CloudTrail console", "AWS Config rule") |
| Scope | Optional | What systems or environments the control covers |
| Owner | Optional | Team or individual responsible |

### Example Input

```json
{
  "organization": "Acme Financial Services",
  "environment": "AWS Production - CDE",
  "controls": [
    {
      "name": "S3 server-side encryption with customer-managed KMS keys",
      "category": "Encryption at Rest",
      "tool": "AWS KMS, Terraform",
      "evidence": "Terraform modules in platform-infra repo, AWS Config rule s3-bucket-server-side-encryption-enabled",
      "scope": "All S3 buckets in CDE accounts"
    },
    {
      "name": "CloudTrail multi-region logging with log file validation",
      "category": "Audit Logging",
      "tool": "AWS CloudTrail",
      "evidence": "CloudTrail console, Terraform configuration, CloudWatch alarms on trail status",
      "scope": "All AWS accounts"
    },
    {
      "name": "IAM roles with least-privilege policies enforced via Terraform",
      "category": "Access Control",
      "tool": "AWS IAM, Terraform",
      "evidence": "IAM policy documents in Terraform repo, quarterly access reviews in ServiceNow",
      "scope": "All CDE workloads"
    }
  ]
}
```

The user can also provide controls conversationally:

```
We have KMS encryption on all S3 buckets and RDS instances in the CDE. 
CloudTrail is enabled multi-region with log validation. IAM policies are 
managed through Terraform with quarterly access reviews. VPC flow logs 
are on in all CDE VPCs. We run Trivy scans in CI/CD and Qualys for 
vulnerability management. Map this against PCI DSS for our upcoming audit.
```

## Compliance Frameworks

Four framework reference files are available in `references/`. Load the relevant one(s) based on the user's request.

| Framework | File | Use When |
|-----------|------|----------|
| PCI DSS v4.0 | `references/pci-dss-v4.md` | Payment card environments, cardholder data processing |
| SOC 2 Type II | `references/soc2.md` | Service organization controls, trust services criteria |
| NIST CSF 2.0 | `references/nist-csf.md` | General cybersecurity framework, federal alignment |
| CIS AWS Benchmarks | `references/cis-aws.md` | AWS-specific security configuration baselines |

Multiple frameworks can be mapped simultaneously. When doing so, generate the cross-framework coverage view showing where controls satisfy requirements across standards.

## Mapping Process

### Step 1: Normalize Controls Inventory

Parse the user's input into a structured controls list. For each control, identify:
- What it does (the security/compliance function)
- How it is implemented (the tool or configuration)
- Where the evidence lives (how an auditor would verify it)
- What it covers (scope of applicability)

### Step 2: Load Framework Requirements

Read the relevant framework reference file(s). Each requirement includes:
- **Requirement ID**: Framework-specific identifier
- **Requirement title**: What must be achieved
- **Category**: Logical grouping within the framework
- **Evidence expectations**: What an auditor looks for to confirm compliance
- **Common controls**: Typical implementations that satisfy this requirement

### Step 3: Map Controls to Requirements

For each framework requirement, evaluate whether the controls inventory includes one or more controls that satisfy it. A requirement can be:

- **Satisfied**: One or more controls directly address the requirement with verifiable evidence
- **Partially satisfied**: Controls exist but coverage is incomplete (e.g., encryption at rest is enabled but only on some data stores, not all)
- **Gap**: No control in the inventory addresses this requirement
- **Not applicable**: The requirement does not apply to the environment (document the justification)

Important mapping principles:
- **One control can satisfy multiple requirements.** A CloudTrail configuration may satisfy audit logging, change detection, and access monitoring requirements simultaneously.
- **One requirement may need multiple controls.** An access control requirement may need both IAM policies AND access review processes to be fully satisfied.
- **Partial coverage is not compliance.** If encryption is required on all data stores and only S3 is encrypted, the requirement is partially satisfied, not satisfied.
- **Process controls matter.** Some requirements cannot be satisfied by technology alone. Access reviews, incident response procedures, and security awareness training are process controls that need documented evidence.

### Step 4: Generate Evidence Matrix

Follow this output structure:

```
## Evidence Matrix: [Framework Name]

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| X.X.X  | [Title]     | [Status] | [Mapped control(s)] | [Evidence location] | [If gap or partial] |

Status indicators:
- ✅ Satisfied
- ⚠️ Partially Satisfied
- ❌ Gap
- N/A Not Applicable
```

### Step 5: Generate Gap Analysis

For each gap or partially satisfied requirement:

```
## Gap Analysis

### [PRIORITY] Gap: [Requirement ID] - [Requirement Title]

**Status**: [Gap | Partially Satisfied]
**Framework(s)**: [Which frameworks this gap affects]
**Risk**: [What exposure exists without this control]
**Remediation**:
- [Specific action to close the gap]
- [Tool or configuration to implement]
- [Evidence to collect once remediated]
**Estimated Effort**: [T-shirt size]
**Recommended Owner**: [Team or role]
```

Priority is based on:
- **Critical**: Direct exposure of regulated data, likely audit finding
- **High**: Missing detective or preventive control, probable audit observation
- **Medium**: Incomplete coverage or missing documentation, possible audit observation
- **Low**: Best practice gap, unlikely to result in an audit finding but recommended

### Step 6: Generate Cross-Framework Coverage (Multi-Framework Only)

When mapping against multiple frameworks, show where controls provide cross-framework coverage:

```
## Cross-Framework Coverage

| Control | PCI DSS | SOC 2 | NIST CSF | CIS AWS |
|---------|---------|-------|----------|---------|
| KMS encryption at rest | 3.5.1 | CC6.1 | PR.DS-1 | 2.1.1 |
| CloudTrail logging | 10.2.1 | CC7.2 | DE.CM-1 | 3.1 |
| IAM least privilege | 7.2.1 | CC6.3 | PR.AC-4 | 1.16 |
```

This view demonstrates to auditors and leadership that the controls investment serves multiple compliance obligations, which is valuable for justifying security spend.

### Step 7: Generate Audit Narrative

A 3-5 paragraph prose summary suitable for:
- Opening an audit engagement with the auditor
- Reporting to the CISO or CIO on compliance readiness
- Including in a board-level risk report

The narrative should frame compliance posture in terms of coverage percentage, gap severity, remediation progress, and organizational risk rather than listing individual controls.

## Tone and Framing

Write as a compliance advisor, not an auditor. The goal is to help the team prepare effectively, not to generate findings against them.

- Frame gaps as "areas to strengthen before the audit" rather than "failures"
- Emphasize cross-framework coverage as evidence of efficient controls investment
- Acknowledge that compliance is continuous, not a point-in-time checkbox
- Be specific about what an auditor will ask for and how to have it ready

When writing the audit narrative, be honest about gaps but frame them with remediation context. "Three gaps were identified, two of which have remediation in progress with target completion before the audit window" is more useful than "Three gaps exist."

## Edge Cases

- **Inherited controls**: If the organization uses a cloud provider (AWS, Azure, GCP), some controls are inherited from the provider's own compliance certifications. Note these as "Inherited - [provider]" and reference the provider's compliance documentation (e.g., AWS Artifact).
- **Compensating controls**: If a requirement cannot be met directly, the user may have a compensating control. Document it as such and note that the auditor will need to approve the compensating control.
- **Shared responsibility**: Cloud environments have shared responsibility models. The evidence matrix should clearly distinguish between provider-managed controls and customer-managed controls.
- **Multiple environments**: If the user has different control sets for different environments (production vs. non-production, CDE vs. non-CDE), generate separate matrices or clearly scope each mapping.
- **Missing evidence locations**: If the user describes controls but not where the evidence lives, flag this in the matrix. A control without verifiable evidence is effectively a gap from an auditor's perspective.
