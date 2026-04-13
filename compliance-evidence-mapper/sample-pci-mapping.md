# Compliance Evidence Mapping: Acme Financial Services
## PCI DSS v4.0 - CDE Production Environment

**Date**: 2026-03-15
**Prepared for**: Annual PCI DSS Assessment
**Scope**: AWS Production accounts within the Cardholder Data Environment

---

## Compliance Summary

| Status | Count | Percentage |
|--------|-------|------------|
| ✅ Satisfied | 22 | 73% |
| ⚠️ Partially Satisfied | 5 | 17% |
| ❌ Gap | 2 | 7% |
| N/A Not Applicable | 1 | 3% |
| **Total** | **30** | |

**Overall Posture**: 22 of 30 applicable requirements fully satisfied. Five requirements are partially satisfied with remediation in progress. Two gaps require new controls before the audit window.

---

## Evidence Matrix

### Requirement 1: Network Security Controls

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 1.2.1 | CDE network segmentation | ✅ | Dedicated CDE VPC with isolated subnets, security groups restricting cross-boundary traffic | Terraform VPC configuration in platform-infra repo, VPC flow log analysis reports | |
| 1.2.5 | Ports/protocols identified | ✅ | Security group rules documented and managed via Terraform | Terraform security group modules, quarterly port review in Confluence | |
| 1.3.1 | Inbound traffic restricted | ✅ | Security groups allow only ALB ingress on 443, no SSH from internet | Terraform configurations, AWS Config rule restricted-ssh | |
| 1.3.2 | Outbound traffic restricted | ⚠️ | Egress security groups on ECS tasks, VPC endpoints for AWS services | Terraform configurations | Egress filtering does not cover all internet-bound traffic. NAT gateway allows unrestricted outbound. Remediation: deploy outbound proxy for CDE. |
| 1.4.1 | NSCs between trust boundaries | ✅ | WAF at internet edge, ALB with TLS, security groups between tiers | WAF rule configurations, ALB listener configs, security group rules in Terraform | |

### Requirement 2: Secure Configuration

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 2.2.1 | Configuration standards | ✅ | Terraform modules with security defaults, CIS-benchmarked AMIs, hardened container base images | Terraform module registry, AMI build pipeline, Dockerfile base image policy | |
| 2.2.7 | Encrypted admin access | ✅ | SSM Session Manager for all administrative access, no SSH keys deployed | SSM Session Manager configuration, IAM policies restricting SSH | |

### Requirement 3: Protect Stored Data

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 3.5.1 | Data encryption at rest | ✅ | KMS encryption with CMKs on all S3, RDS, EBS, DynamoDB in CDE | Terraform encryption configurations, AWS Config rules (s3-bucket-server-side-encryption-enabled, rds-storage-encrypted) | |
| 3.6.1 | Key management procedures | ✅ | KMS automatic key rotation enabled, key policies scoped to CDE roles | KMS key configurations in Terraform, CloudTrail key usage logs, key policy documents | |

### Requirement 4: Protect Data in Transit

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 4.2.1 | Encryption in transit | ✅ | TLS 1.2+ on all ALB listeners, RDS SSL enforcement, API Gateway TLS | ALB SSL policy configuration, RDS parameter group with require_secure_transport, ACM certificate inventory | |

### Requirement 5: Malware Protection

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 5.2.1 | Anti-malware deployed | ⚠️ | ECR scan-on-push enabled, Trivy in CI/CD pipeline | ECR scanning configuration, CI/CD pipeline logs | No runtime malware detection on ECS tasks. Container images are scanned at build but not monitored at runtime. |
| 5.3.1 | Anti-malware kept current | ✅ | ECR scan-on-push uses latest vulnerability database, Trivy updated in CI/CD | ECR scan configuration, CI/CD pipeline dependency versions | |

### Requirement 6: Secure Development

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 6.2.4 | Secure coding practices | ✅ | Semgrep SAST in CI/CD, Trivy dependency scanning, PR review gates | CI/CD pipeline configurations, Semgrep rule sets, PR merge requirements | |
| 6.3.1 | Vulnerability management | ✅ | AWS Inspector, Trivy scanning, Qualys external scanning, Jira tracking | Inspector configurations, scan reports, Jira vulnerability tracking board | |
| 6.3.3 | Patch management | ⚠️ | Container base image rebuild pipeline, SSM Patch Manager for EC2 | CI/CD pipeline, SSM patch compliance reports | Patch SLAs documented but no automated enforcement. Critical patches are applied within 72 hours by practice but this is not policy-enforced. |

### Requirement 7: Access Control

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 7.2.1 | Access control system | ✅ | AWS IAM with Terraform-managed policies, Okta SSO | Terraform IAM configurations, Okta application assignments | |
| 7.2.2 | Role-based access | ✅ | IAM roles separated by function (dev, ops, admin, read-only) | Terraform role definitions, role-to-function mapping document | |
| 7.2.5 | Periodic access reviews | ✅ | Quarterly access reviews via ServiceNow, IAM Access Analyzer | ServiceNow access review records, Access Analyzer findings log | |

### Requirement 8: Authentication

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 8.3.1 | Authentication required | ✅ | Okta SSO for all human access, IAM roles for service access | Okta configuration, IAM role trust policies | |
| 8.3.6 | MFA for CDE access | ✅ | Okta MFA enforced, IAM policies require MFA condition | Okta MFA policy, IAM policy conditions | |
| 8.6.1 | Service account management | ⚠️ | IAM roles used instead of static keys for most services, Secrets Manager for third-party integrations | Terraform IAM configurations, Secrets Manager rotation configurations | Two legacy integrations still use static API keys. Rotation is manual, not automated. Migration to IAM roles planned for Q2. |

### Requirement 10: Logging and Monitoring

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 10.2.1 | Audit log capture | ✅ | CloudTrail multi-region, S3 access logging, RDS audit logging | CloudTrail configuration, S3 logging configuration, RDS parameter group | |
| 10.2.2 | Admin action logging | ✅ | CloudTrail management events, console sign-in logging | CloudTrail event selectors, CloudWatch alarms on privileged actions | |
| 10.3.1 | Log integrity | ✅ | CloudTrail log file validation, S3 Object Lock on log bucket | CloudTrail validation setting, S3 Object Lock configuration | |
| 10.4.1 | Daily log review | ⚠️ | GuardDuty findings reviewed, Security Hub aggregation, CloudWatch alarms | GuardDuty console, Security Hub dashboard, alarm configurations | Automated alerting is strong but no documented daily review procedure. Auditor will ask for evidence of review cadence. |
| 10.5.1 | 12-month log retention | ✅ | CloudWatch Logs 90-day retention + S3 Glacier archival for 12 months | CloudWatch retention settings, S3 lifecycle policies | |

### Requirement 11: Security Testing

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 11.3.1 | Internal vulnerability scans | ✅ | AWS Inspector continuous scanning, quarterly Qualys scans | Inspector findings, Qualys scan reports | |
| 11.3.2 | External ASV scans | ✅ | Quarterly ASV scans via Qualys | ASV scan reports with passing status | |
| 11.4.1 | Intrusion detection | ❌ | GuardDuty enabled | GuardDuty configuration | GuardDuty provides threat detection but is not formally documented as the IDS/IPS control for PCI. Need to document GuardDuty as the IDS, define alert thresholds, and demonstrate incident response integration. |

### Requirement 12: Organizational Policies

| Req ID | Requirement | Status | Control(s) | Evidence | Gap/Notes |
|--------|-------------|--------|------------|----------|-----------|
| 12.5.2 | Annual scope validation | ✅ | Annual CDE scope review, tagged CDE resources | Scope review records, resource tagging (ComplianceScope=PCI) | |
| 12.10.1 | Incident response plan | ❌ | IR runbooks exist per service | PagerDuty configurations, service runbooks | Runbooks exist but no unified IR plan covering the CDE. No evidence of annual IR testing (tabletop exercise). Need to consolidate runbooks into a CDE IR plan and schedule a tabletop exercise before the audit. |

---

## Gap Analysis

### CRITICAL Gap: Requirement 12.10.1 - Incident Response Plan

**Status**: Gap
**Risk**: Auditor will issue a finding if no unified CDE incident response plan exists with evidence of testing. This is a commonly cited finding in PCI assessments.
**Remediation**:
- Consolidate existing service-level runbooks into a CDE-wide IR plan covering detection, containment, eradication, recovery, and post-incident review
- Define roles and responsibilities for IR within the CDE
- Schedule and execute a tabletop exercise before the audit window
- Document the tabletop exercise results and any follow-up actions
**Estimated Effort**: Medium (2-3 weeks for plan creation + tabletop)
**Recommended Owner**: SRE + Information Security

### HIGH Gap: Requirement 11.4.1 - Intrusion Detection Documentation

**Status**: Gap (tool exists, documentation insufficient)
**Risk**: GuardDuty is active and functional, but without formal documentation as the IDS control and defined response procedures, the auditor may not accept it as satisfying the requirement.
**Remediation**:
- Document GuardDuty as the formal IDS/IPS control for the CDE
- Define severity-to-response mappings for GuardDuty finding types
- Create a GuardDuty findings response runbook
- Demonstrate integration with incident response workflow (PagerDuty escalation)
**Estimated Effort**: Small (1 week)
**Recommended Owner**: Platform Engineering + Information Security

### HIGH Partial: Requirement 1.3.2 - Outbound Traffic Restriction

**Status**: Partially Satisfied
**Risk**: Unrestricted outbound through NAT gateway could be flagged as insufficient egress control. Risk of data exfiltration via unrestricted outbound channels.
**Remediation**:
- Deploy an outbound proxy (Squid or AWS Network Firewall) for CDE egress
- Restrict NAT gateway usage to proxy-mediated traffic
- Define and enforce an egress allowlist for CDE workloads
**Estimated Effort**: Large (4-6 weeks including testing)
**Recommended Owner**: Platform Engineering

### MEDIUM Partial: Requirement 5.2.1 - Runtime Malware Detection

**Status**: Partially Satisfied
**Risk**: Build-time scanning is solid but lack of runtime protection may be noted as an observation. Unlikely to be a formal finding given container-based architecture.
**Remediation**:
- Evaluate GuardDuty Runtime Monitoring for ECS
- Alternatively, document the compensating control: immutable container images, scan-on-push, no shell access to running containers
**Estimated Effort**: Small (1-2 weeks for evaluation)
**Recommended Owner**: Platform Engineering + SRE

### MEDIUM Partial: Requirement 6.3.3 - Patch SLA Enforcement

**Status**: Partially Satisfied
**Risk**: Auditor may ask for evidence that critical patches are applied within a defined timeframe. Current practice is good but not policy-enforced.
**Remediation**:
- Formalize patching SLA policy (e.g., critical: 72 hours, high: 7 days, medium: 30 days)
- Implement automated compliance tracking via AWS Config or SSM
- Generate monthly patch compliance reports
**Estimated Effort**: Small (1 week for policy + automation)
**Recommended Owner**: Platform Engineering

### MEDIUM Partial: Requirement 8.6.1 - Legacy Static API Keys

**Status**: Partially Satisfied
**Risk**: Two legacy integrations using static API keys with manual rotation. Low risk given limited scope but auditor will note it.
**Remediation**:
- Migrate legacy integrations to IAM role-based authentication
- If migration is not possible, implement automated key rotation via Secrets Manager
- Document the legacy integrations and rotation schedule as a compensating control
**Estimated Effort**: Medium (2-3 weeks per integration)
**Recommended Owner**: Platform Engineering + Application Teams

### LOW Partial: Requirement 10.4.1 - Daily Log Review Procedure

**Status**: Partially Satisfied
**Risk**: Automated alerting provides continuous monitoring, but auditor may ask for evidence of structured daily review. Low risk given strong automated detection.
**Remediation**:
- Document a daily security review procedure (review GuardDuty findings, Security Hub summary, CloudWatch alarm history)
- Assign daily review rotation to the SRE team
- Create a daily review checklist with sign-off (even if automated alerts are the primary mechanism)
**Estimated Effort**: Small (2-3 days)
**Recommended Owner**: SRE

---

## Audit Narrative

Acme Financial Services maintains a strong compliance posture across the PCI DSS cardholder data environment, with 73% of applicable requirements fully satisfied and an additional 17% partially satisfied with active remediation plans. The infrastructure is built on AWS with a Terraform-managed, security-by-default approach: all data stores are encrypted with customer-managed KMS keys, network segmentation isolates the CDE from non-CDE environments, and access control is enforced through SSO with MFA and least-privilege IAM policies managed as code.

The two identified gaps are documentation-oriented rather than architectural. The IDS/IPS requirement (11.4.1) is functionally met through GuardDuty but needs formal documentation and response procedure mapping. The incident response plan (12.10.1) requires consolidation of existing service-level runbooks into a CDE-wide plan with tabletop exercise evidence. Both gaps have clear remediation paths and can be addressed within four weeks.

The partially satisfied requirements reflect a mature environment with specific areas for hardening: outbound traffic filtering (the most significant infrastructure gap), runtime container protection, patch SLA formalization, and legacy API key migration. Remediation is prioritized by risk, with the egress filtering work on the critical path and the remaining items planned for completion before the audit engagement window.

Controls investment in this environment provides broad cross-framework coverage. The encryption, logging, access control, and monitoring controls that satisfy PCI DSS requirements also cover corresponding SOC 2 trust services criteria and NIST CSF subcategories, reducing the incremental effort for multi-framework compliance.
