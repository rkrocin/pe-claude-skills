# Cross-Framework Control Coverage: Acme Financial Services

## Overview

This matrix shows how existing infrastructure controls map across multiple compliance frameworks simultaneously. A single well-implemented control often satisfies requirements in PCI DSS, SOC 2, NIST CSF, and CIS AWS Benchmarks, demonstrating efficient security investment.

**Frameworks Mapped**: PCI DSS v4.0, SOC 2 Type II, NIST CSF 2.0, CIS AWS Foundations

---

## Cross-Framework Coverage Matrix

| Control | PCI DSS v4.0 | SOC 2 | NIST CSF 2.0 | CIS AWS |
|---------|-------------|-------|-------------|---------|
| **Encryption at Rest (KMS CMK)** | 3.5.1, 3.6.1 | CC6.1, C1.1 | PR.DS-1 | 2.1.1, 2.3.1 |
| **Encryption in Transit (TLS 1.2+)** | 4.2.1 | CC6.7 | PR.DS-2 | 2.1.2 |
| **CloudTrail Multi-Region** | 10.2.1, 10.2.2, 10.3.1 | CC7.2, CC8.1 | PR.PT-1, DE.CM-1 | 3.1, 3.2, 3.4 |
| **VPC Flow Logs** | 1.2.1 | CC7.1 | DE.CM-1 | 3.9 |
| **IAM Least-Privilege Policies** | 7.2.1, 7.2.2 | CC6.1, CC6.3 | PR.AC-4 | 1.16 |
| **SSO with MFA** | 8.3.1, 8.3.6 | CC6.1, CC6.2 | PR.AC-1 | 1.10 |
| **Quarterly Access Reviews** | 7.2.5 | CC6.3 | PR.AC-4 | - |
| **S3 Public Access Block** | 1.3.1 | CC6.7, CC6.1 | PR.DS-5 | 2.1.5 |
| **Security Group Restrictions** | 1.3.1, 1.2.5 | CC6.6 | PR.AC-4 | 5.1, 5.3 |
| **CDE VPC Segmentation** | 1.2.1, 1.4.1 | CC6.1 | PR.AC-4 | - |
| **ECR Scan-on-Push** | 5.2.1, 6.3.1 | CC6.8 | DE.CM-4 | - |
| **Semgrep SAST in CI/CD** | 6.2.4 | CC6.8, CC8.1 | PR.IP-12 | - |
| **Trivy Dependency Scanning** | 6.3.1 | CC6.8 | ID.RA-1 | - |
| **AWS Inspector** | 11.3.1 | CC7.1 | ID.RA-1 | - |
| **GuardDuty** | 11.4.1 | CC7.1, CC7.2 | DE.CM-1, DE.CM-7 | - |
| **Terraform IaC Management** | 2.2.1 | CC8.1 | PR.IP-1, PR.IP-3 | - |
| **SSM Session Manager** | 2.2.7 | CC6.1 | PR.AC-3 | - |
| **RDS Automated Backups** | - | A1.2 | PR.IP-4 | - |
| **PagerDuty Escalation** | 12.10.1 | CC7.3, CC7.4 | RS.RP-1, DE.DP-4 | - |
| **CloudWatch Alarms** | 10.4.1 | CC7.1 | DE.CM-7 | 4.1, 4.3, 4.4 |
| **Secrets Manager** | 8.6.1 | CC6.1 | PR.AC-1 | - |
| **KMS Key Rotation** | 3.6.1 | CC6.1 | PR.DS-1 | - |

---

## Coverage Summary by Framework

| Framework | Total Requirements | Satisfied | Partial | Gap | Coverage |
|-----------|--------------------|-----------|---------|-----|----------|
| PCI DSS v4.0 | 30 | 22 | 5 | 2 | 73% full, 90% partial+ |
| SOC 2 Type II | 22 | 18 | 3 | 1 | 82% full, 95% partial+ |
| NIST CSF 2.0 | 28 | 23 | 4 | 1 | 82% full, 96% partial+ |
| CIS AWS | 20 | 17 | 2 | 1 | 85% full, 95% partial+ |

## High-Value Controls

The following controls provide the broadest cross-framework coverage, satisfying requirements in three or more frameworks with a single implementation:

| Control | Frameworks Covered | Total Requirements Satisfied |
|---------|-------------------|------------------------------|
| CloudTrail Multi-Region | PCI, SOC 2, NIST, CIS | 7 |
| KMS Encryption at Rest | PCI, SOC 2, NIST, CIS | 6 |
| IAM Least-Privilege | PCI, SOC 2, NIST, CIS | 5 |
| SSO with MFA | PCI, SOC 2, NIST, CIS | 5 |
| S3 Public Access Block | PCI, SOC 2, NIST, CIS | 4 |
| Security Group Restrictions | PCI, SOC 2, NIST, CIS | 4 |
| GuardDuty | PCI, SOC 2, NIST | 4 |
| CloudWatch Alarms | PCI, SOC 2, NIST, CIS | 4 |

This cross-framework view demonstrates that the 22 controls in the inventory satisfy 80+ individual requirements across four frameworks. Investing in these controls once provides compliance coverage across multiple regulatory obligations, which is significantly more efficient than treating each framework as an independent compliance program.

---

## Gap Overlap

Gaps in one framework often correspond to gaps in others. Remediating a single gap can close findings across multiple frameworks:

| Gap | PCI DSS | SOC 2 | NIST CSF | CIS AWS |
|-----|---------|-------|----------|---------|
| Unified IR plan + tabletop | 12.10.1 | CC7.4, CC7.5 | RS.RP-1 | - |
| IDS documentation | 11.4.1 | CC7.1 | DE.CM-1 | - |
| Egress traffic filtering | 1.3.2 | CC6.6 | PR.DS-5 | - |

Remediating the IR plan gap alone closes findings in PCI DSS, SOC 2, and NIST CSF simultaneously.
