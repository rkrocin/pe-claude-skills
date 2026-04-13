---
name: standards-driven-iac
description: >
  Generate AWS infrastructure-as-code (Terraform HCL or CloudFormation JSON/YAML) that complies
  with company standards, policies, and guidelines provided as uploaded documents (.docx or .md).
  Use this skill whenever the user uploads a standards document, policy document, cloud guidelines,
  tagging standards, security baseline, or infrastructure policy and wants to generate IaC templates
  that comply with those standards. Also trigger when the user asks to create AWS resources based
  on company policy, generate Terraform or CloudFormation from a standards document, build compliant
  infrastructure templates, or produce IaC that follows organizational guidelines. Supports both
  Terraform HCL and CloudFormation JSON/YAML output. Reads .docx files via pandoc and .md files
  directly.
---

# Standards-Driven IaC Generator

Generate AWS infrastructure-as-code that complies with company standards, policies, and guidelines extracted from uploaded documents.

## What This Skill Does

Takes uploaded company standards documents (.docx or .md) and a resource request, then generates:

1. **Compliant IaC templates** (Terraform HCL or CloudFormation) that satisfy all extracted policy requirements
2. **Standards Compliance Map** showing which policy from the document each configuration element satisfies
3. **Variables/Parameters** with defaults that match organizational standards
4. **Deviation Report** if any requested resource cannot fully comply, explaining what deviates and why

## Workflow

### Step 1: Read the Standards Document

When the user uploads a standards document, read it using the appropriate method:

**For .docx files:**
```bash
pandoc /mnt/user-data/uploads/standards.docx -t markdown -o /home/claude/standards.md
cat /home/claude/standards.md
```

**For .md files:**
```bash
cat /mnt/user-data/uploads/standards.md
```

**For .pdf files:**
Refer to the pdf-reading skill at `/mnt/skills/public/pdf-reading/SKILL.md` for extraction.

If the document is very large (>50 pages), scan the table of contents or section headers first to identify the most relevant sections, then read those in detail.

### Step 2: Extract Policies

Parse the document and extract infrastructure policies into a structured format. Policies typically fall into these categories:

| Category | What to Look For |
|----------|-----------------|
| **Naming conventions** | Resource naming patterns, prefix/suffix requirements, case rules, environment identifiers |
| **Tagging standards** | Required tags, tag key naming, tag value formats, propagation rules |
| **Encryption requirements** | At-rest encryption mandates, KMS key requirements (CMK vs. AWS-managed), in-transit TLS requirements |
| **Network standards** | VPC CIDR ranges, subnet sizing, AZ distribution, security group rules, public access restrictions |
| **IAM policies** | Role naming conventions, least-privilege requirements, trust policy restrictions, MFA requirements |
| **Logging and monitoring** | Required logging (CloudTrail, flow logs, access logs), retention periods, alerting requirements |
| **Compute standards** | Approved instance families, AMI requirements, auto-scaling policies, patching requirements |
| **Storage standards** | S3 bucket policies, lifecycle rules, versioning requirements, access patterns |
| **Database standards** | RDS instance classes, Multi-AZ requirements, backup retention, parameter groups |
| **Cost governance** | Budget tags, instance generation requirements, reserved capacity expectations, lifecycle policies |
| **Compliance scope** | PCI/SOC2/HIPAA tagging, CDE boundary requirements, data classification tags |

Extract each policy as a structured rule:

```
Policy: [What the policy requires]
Source: [Section/page of the document where this policy is stated]
Category: [Which category above]
Applies to: [Which AWS resource types]
Implementation: [How this translates to IaC configuration]
```

### Step 3: Confirm Extraction with User

Before generating IaC, present the extracted policies to the user in a summary table:

```
I extracted N policies from your standards document. Here are the key requirements 
I'll apply to the generated infrastructure:

| # | Policy | Category | Applies To |
|---|--------|----------|------------|
| 1 | All S3 buckets must use SSE-KMS with CMK | Encryption | S3 |
| 2 | Required tags: Environment, Owner, CostCenter, Application | Tagging | All resources |
| ...

Does this look correct? Should I adjust anything before generating?
```

This confirmation step prevents generating templates based on misinterpreted policies. If the document is ambiguous, ask for clarification rather than guessing.

### Step 4: Collect Resource Requirements

Understand what the user wants to build. Accept this in any format:

- "I need an S3 bucket for storing transaction logs"
- "Create a VPC with public and private subnets across 3 AZs"
- "Set up an RDS PostgreSQL instance for our payments service"
- A detailed architecture description
- A list of resources

For each resource, determine:
- Resource type (S3, RDS, VPC, EC2, Lambda, etc.)
- Purpose (helps determine compliance scope and naming)
- Environment (dev, staging, production)
- Compliance scope (PCI, SOC2, general)
- Any resource-specific requirements beyond the standards

### Step 5: Generate IaC

Generate the infrastructure code in the user's preferred format:

**Terraform HCL (default):**
- `main.tf` - Resource definitions
- `variables.tf` - Input variables with defaults matching standards
- `outputs.tf` - Output values
- `terraform.tfvars.example` - Example variable values
- `locals.tf` - Computed values (standard tags, naming)

**CloudFormation:**
- Single YAML or JSON template
- Parameters section with allowed values matching standards
- Conditions for environment-specific configuration
- Outputs for cross-stack references

### Generation Principles

**Every configuration element must trace to a policy.** If the generated code sets `storage_encrypted = true`, it should be because the standards document requires encryption at rest. Do not add configuration that is not supported by the extracted policies or the user's request.

**Use variables for organizational values.** Do not hardcode CostCenter, Owner, or environment-specific values. Use variables with sensible defaults extracted from the standards.

**Standard tags as a locals block.** Create a `locals` block (Terraform) or Mappings (CloudFormation) that computes the standard tag set once and applies it to all resources. This prevents tag drift across resources.

**Naming convention as a local.** If the standards define a naming pattern (e.g., `{env}-{app}-{resource_type}`), implement it as a computed local, not repeated string interpolation.

**Comment each policy-driven configuration.** Add inline comments referencing the policy source:

```hcl
# Per Section 3.2: All S3 buckets must use SSE-KMS with customer-managed keys
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}
```

**Handle ambiguity explicitly.** If the standards document says "encryption should be enabled" without specifying KMS vs. AES-256, generate the more secure option (KMS) and add a comment noting the ambiguity and the decision made.

### Step 6: Generate Compliance Map

After generating the IaC, produce a compliance map showing how each generated configuration element maps to a policy:

```
## Standards Compliance Map

| Resource | Configuration | Policy | Source |
|----------|--------------|--------|--------|
| aws_s3_bucket.logs | server_side_encryption: aws:kms | Encryption at rest with CMK | Section 3.2 |
| aws_s3_bucket.logs | public_access_block: all true | No public S3 access | Section 4.1 |
| aws_s3_bucket.logs | tags: Environment, Owner, CostCenter, Application | Required tagging | Section 2.1 |
| aws_s3_bucket.logs | lifecycle_rule: transition to Glacier at 90 days | Storage lifecycle management | Section 5.3 |
| ... | ... | ... | ... |
```

### Step 7: Generate Deviation Report (if applicable)

If any requested resource cannot fully comply with the extracted standards, produce a deviation report:

```
## Deviation Report

### Deviation 1: RDS Multi-AZ in Development
**Policy**: Section 6.2 states "All RDS instances must be Multi-AZ"
**Generated**: `multi_az = false` in development configuration
**Reason**: Multi-AZ in development doubles cost without meaningful benefit. 
            Production configuration does set multi_az = true.
**Recommendation**: Add an exception for non-production environments in the 
                   standards document, or accept the deviation for dev/staging.
```

## Output Formats

### Terraform (Default)

Generate standard Terraform file structure:

```hcl
# main.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Standard tags applied to all resources
locals {
  standard_tags = {
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Application = var.application
    ManagedBy   = "terraform"
    # Additional tags from standards document
  }
  
  # Naming convention: {env}-{app}-{resource_type}
  name_prefix = "${var.environment}-${var.application}"
}
```

### CloudFormation

Generate a single template with parameters and conditions:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: '[Resource description] - Generated from company standards'

Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, staging, production]
  Owner:
    Type: String
  CostCenter:
    Type: String
  Application:
    Type: String

Conditions:
  IsProduction: !Equals [!Ref Environment, production]
```

## Handling Common Standards Patterns

### Naming Conventions
Standards documents often define naming patterns. Common formats:
- `{environment}-{application}-{resource}` (e.g., `prod-payments-api`)
- `{org}-{env}-{app}-{resource}` (e.g., `acme-prod-payments-s3`)
- `{department}/{environment}/{application}` (for S3 prefixes or tags)

Implement as a `locals` block in Terraform or a `Fn::Sub` pattern in CloudFormation.

### Tagging Standards
Tags are the most common standard. Typical required tags:
- Environment, Owner, CostCenter, Application (nearly universal)
- DataClassification, ComplianceScope (regulated environments)
- CreatedBy, ManagedBy (automation tracking)
- ExpirationDate, Project (lifecycle management)

Implement as a merged tag map that combines standard tags with resource-specific tags.

### Encryption Standards
Three common patterns:
1. "All data must be encrypted at rest" - Apply default encryption to every data store
2. "Use customer-managed KMS keys" - Create or reference CMK, never use AWS-managed keys
3. "Minimum TLS 1.2" - Configure ssl_policy on load balancers, parameter groups on databases

### Network Standards
Common patterns:
- CIDR allocation scheme (e.g., /16 per environment, /24 per subnet)
- AZ distribution requirements (minimum 2 AZs for production)
- No public IPs on compute resources
- VPC endpoints for AWS service access (avoid NAT gateway for S3/DynamoDB)

## Edge Cases

- **Conflicting policies**: If the standards document contains contradictions (e.g., "use AES-256 for S3 encryption" in one section and "use KMS for all encryption" in another), flag the conflict to the user and ask which takes precedence.
- **Vague policies**: If a policy is stated without specifics (e.g., "appropriate encryption"), apply the most secure reasonable interpretation and document the assumption.
- **Missing categories**: If the standards document does not address a category (e.g., no logging requirements), generate resources without those configurations and note in the compliance map that the standards are silent on that category.
- **Multiple documents**: If the user uploads multiple standards documents, reconcile them by treating more specific policies as overriding general ones. Flag any conflicts.
- **Non-AWS resources**: If the standards reference resources outside AWS, note them as out of scope but include them in the compliance map as items needing separate implementation.
- **Outdated standards**: If the standards reference deprecated AWS features (e.g., classic ELB, gp2 volumes), generate using current equivalents and note the update in the deviation report.

## File Output

Save generated IaC to `/home/claude/` during generation, then copy final files to `/mnt/user-data/outputs/` and present using `present_files`. For Terraform, output the full file set. For CloudFormation, output a single template file plus the compliance map as a separate markdown file.
