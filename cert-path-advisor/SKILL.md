---
name: cert-path-advisor
description: >
  Analyze a resume and job description to recommend certifications and certification paths that
  close skill gaps and strengthen candidacy. Use this skill whenever the user uploads a resume and
  a job description (or describes a target role) and wants certification recommendations, gap
  analysis, or a prioritized credential plan. Also trigger when the user asks which certifications
  would help them get a specific job, how to prioritize certifications for a career move, which
  certs matter for a particular role or industry, or how their current certifications compare to
  what a role requires. Supports reading resumes and JDs from .docx, .pdf, .md, .txt, or pasted
  text. Covers AWS, Azure, GCP, Kubernetes, security (ISC2, ISACA, CompTIA, SANS), DevOps, FinOps,
  AI/ML, and project management certifications.
---

# Certification Path Advisor

Analyze a resume and job description to recommend certifications that close skill gaps and strengthen candidacy for a target role.

## What This Skill Does

Takes a resume and a job description (uploaded or pasted) and generates:

1. **Skills Gap Analysis** comparing current credentials and experience against role requirements
2. **Certification Recommendations** prioritized by impact on candidacy
3. **Certification Path** sequencing recommendations with dependencies and overlap optimization
4. **Existing Credential Assessment** evaluating which current certifications are relevant to the target role
5. **ROI Analysis** estimating preparation effort, cost, and hiring signal strength for each recommendation

## Workflow

### Step 1: Read Input Documents

Accept resume and job description in any format:

**Uploaded files:**
- `.docx`: Convert via pandoc: `pandoc file.docx -t markdown -o /home/claude/output.md`
- `.pdf`: Use pdf-reading skill at `/mnt/skills/public/pdf-reading/SKILL.md`
- `.md` or `.txt`: Read directly
- If the content is already in the conversation context (pasted or visible), use it directly without file operations

**Pasted text:** Accept resume and/or JD pasted directly into the conversation.

**Partial inputs:** If only a resume is provided, ask about the target role. If only a JD is provided, ask about current experience. The skill can work with one input but produces better results with both.

### Step 2: Extract Resume Profile

Parse the resume and extract:

| Element | What to Look For |
|---------|-----------------|
| **Current certifications** | Credential names, issuing bodies, dates if listed |
| **Technical skills** | Languages, frameworks, cloud platforms, tools, methodologies |
| **Domain experience** | Industries, regulated environments, compliance frameworks |
| **Role level** | IC, Senior IC, Manager, Director, VP (inferred from titles and scope) |
| **Leadership scope** | Team sizes, budget ownership, org-level responsibilities |
| **Years of experience** | Total and per domain (cloud, security, platform, etc.) |
| **Education** | Degrees, fields, institutions |

Build a structured profile:

```
Resume Profile:
- Level: [IC/Manager/Director/VP]
- Years experience: [N total, N in primary domain]
- Primary domain: [Platform engineering, security, cloud, DevOps, etc.]
- Cloud platforms: [AWS, Azure, GCP with depth assessment]
- Current certifications: [List with relevance notes]
- Technical skills: [Grouped by category]
- Domain experience: [Industries, compliance frameworks]
- Leadership scope: [Team size, budget, org span]
```

### Step 3: Extract Job Requirements

Parse the job description and extract:

| Element | What to Look For |
|---------|-----------------|
| **Required certifications** | Explicitly listed as required |
| **Preferred certifications** | Listed as preferred, desired, or nice-to-have |
| **Technical requirements** | Specific technologies, platforms, tools |
| **Domain requirements** | Industry experience, compliance knowledge, regulatory familiarity |
| **Level signals** | Years of experience, scope of responsibility, leadership expectations |
| **Implicit cert signals** | Requirements that imply certification value even if not explicitly listed (e.g., "deep AWS expertise" implies SA Professional value) |

Build a structured requirements profile:

```
Role Requirements:
- Title: [Role title]
- Level: [IC/Manager/Director/VP]
- Required certs: [Explicitly required]
- Preferred certs: [Explicitly preferred]
- Cloud platforms: [Required/preferred with depth]
- Technical requirements: [Specific skills]
- Domain requirements: [Industry, compliance]
- Implicit cert signals: [Inferred from requirements]
```

### Step 4: Gap Analysis

Compare the resume profile against the role requirements across five dimensions:

**1. Certification gaps**: Certifications the role requires or prefers that the candidate does not hold.

**2. Skill gaps**: Technical skills the role requires where the candidate has limited or no demonstrated experience. Identify certifications that would credibly demonstrate these skills.

**3. Domain gaps**: Industry or compliance domain experience the role requires that the candidate lacks. Identify certifications that signal domain credibility.

**4. Level gaps**: If the role is at a higher level than the candidate's current position, identify certifications that signal readiness for the next level (e.g., CISSP for security leadership, AWS SA Professional for architecture leadership).

**5. Credential redundancy**: Current certifications that are superseded by or irrelevant to the target role. Note these so the candidate does not over-invest in renewal.

### Step 5: Generate Recommendations

For each recommended certification, provide:

```
### [Priority]: [Certification Name]

**Why**: [1-2 sentences connecting this cert to the specific gap it closes]
**Signal to hiring manager**: [What this cert tells the hiring manager about the candidate]
**Prerequisites**: [Required certs or experience]
**Preparation effort**: [Estimated hours and weeks]
**Cost**: [Exam fee + primary study resource cost]
**Difficulty**: [Associate/Professional/Expert relative to candidate's experience]
**Overlap with current credentials**: [What existing knowledge transfers]
**ROI assessment**: [High/Medium/Low based on effort vs. hiring signal strength]
```

### Priority Framework

Categorize recommendations into four tiers:

**Tier 1 - High Impact / Close Now** (1-2 certs):
Certifications that are explicitly required or strongly preferred in the JD, or that close the single biggest credibility gap. These should be pursued before applying if timeline allows, or immediately upon starting the job search.

**Tier 2 - Strong Signal / Next Quarter** (2-3 certs):
Certifications that meaningfully strengthen candidacy by demonstrating depth in a required skill area. Not explicitly required but would differentiate the candidate. Pursue after Tier 1 or in parallel if capacity allows.

**Tier 3 - Differentiator / This Year** (2-3 certs):
Certifications that set the candidate apart from other applicants by demonstrating breadth or emerging capability (AI/ML, FinOps, specialized security). Lower urgency but high long-term value.

**Tier 4 - Nice to Have / Opportunistic** (0-2 certs):
Certifications that add minor value or validate existing knowledge. Pursue only if the candidate has excess study capacity or the cert is very low effort.

### Step 6: Build Certification Path

Sequence the recommended certifications considering:

**Dependencies**: Some certs require others (ISSAP requires CISSP, CKS requires CKA). Sequence these correctly.

**Knowledge overlap**: Certs that share content should be taken sequentially while the material is fresh. Quantify the overlap as weeks of saved prep time.

**Diminishing returns**: Too many certs in the same domain (e.g., five AWS certs) signals exam-taking ability, not breadth. Recommend diversifying across domains after covering the core.

**Timeline alignment**: If the candidate has a specific job search timeline, front-load the highest-impact certs.

Generate a visual path:

```
## Recommended Certification Path

Timeline: [Total months for complete path]

Quarter 1:
├── [Cert 1] (Tier 1) - [N weeks prep]
└── [Cert 2] (Tier 1) - [N weeks prep, [N weeks] overlap savings from Cert 1]

Quarter 2:
├── [Cert 3] (Tier 2) - [N weeks prep]
└── [Cert 4] (Tier 2) - [N weeks prep]

Quarter 3:
├── [Cert 5] (Tier 3) - [N weeks prep]
└── [Cert 6] (Tier 3) - [N weeks prep]
```

## Certification Knowledge Base

Load the appropriate reference file(s) based on the domains involved:

| Domain | File | Certifications Covered |
|--------|------|----------------------|
| AWS | `references/aws.md` | SA Associate/Professional, Developer, SysOps, Security, ML, GenAI, Data Engineer, Database, Networking |
| Security & GRC | `references/security-grc.md` | CISSP, ISSAP, ISSEP, CCSP, CISM, CRISC, CGEIT, CSSLP, GSLC, Security+, CEH, OSCP |
| Cloud & Platform | `references/cloud-platform.md` | CKA, CKAD, CKS, Terraform Associate, FinOps Practitioner/Engineer, Azure/GCP equivalents |
| AI/ML | `references/ai-ml.md` | AWS GenAI, AWS ML Specialty, AWS ML Engineer, AAISM, Google ML Engineer, Azure AI Engineer |
| DevOps & Agile | `references/devops-agile.md` | AWS DevOps Professional, Azure DevOps, GitLab certified, SAFe, PMP, ITIL |

## Analysis Principles

**Certifications are signals, not skills.** A certification tells a hiring manager that the candidate has invested time in learning a domain and can pass an assessment. It does not prove they can do the job. Frame recommendations as signal-enhancers, not skill-replacements.

**Required certs are table stakes.** If the JD explicitly requires a certification, there is no substitute. Recommend obtaining it regardless of the candidate's experience level. Some ATS systems filter on required certifications.

**Preferred certs are differentiators.** The candidate who has them stands out from equally qualified candidates who do not. These have the highest ROI because they move a candidate from "meets requirements" to "exceeds requirements."

**Industry context matters.** A CISSP is near-universal for security leadership in financial services but less common in startups. CKA matters in cloud-native companies but less in mainframe-heavy organizations. Calibrate recommendations to the target industry.

**Level-appropriate recommendations.** A Director pursuing a Director role does not need CompTIA Security+. An IC moving to a Senior IC role does not need CGEIT. Match the certification level to the career level.

**Certification fatigue is real.** Recommending 15 certifications is not helpful. Prioritize ruthlessly. 3-5 well-chosen certs across 6-12 months is a realistic and impactful plan.

## Edge Cases

- **Overqualified candidate**: If the candidate holds more certifications than the role requires, note which certs are most relevant to highlight in the application and which are irrelevant noise. Recommend certs that close specific gaps rather than adding breadth.
- **Career changer**: If the candidate is changing domains (e.g., networking to cloud, development to security), weight foundational certs higher than advanced ones. The path should build credibility in the new domain before going deep.
- **No JD provided**: If only a target role title and company are provided, infer typical requirements from the reference files and industry norms. Note that recommendations are approximate without a specific JD.
- **Non-US certifications**: Some international certifications (CISA, ISO 27001 Lead Auditor, TOGAF) may be relevant depending on the role. Note if the JD signals international or compliance-heavy requirements.
- **Expired certifications**: If the resume lists certifications without current status, note which ones may need renewal and factor renewal effort into the path.
- **Very senior roles (VP+)**: At VP level and above, certifications matter less than track record. Recommend only if specific certs close a visible credibility gap (e.g., a VP of Security without CISSP). Otherwise, note that the candidate's experience likely outweighs certification signals.

## Output Format

Generate the full analysis as a markdown document:

1. Resume profile summary
2. Role requirements summary
3. Gap analysis across five dimensions
4. Prioritized certification recommendations (Tier 1-4)
5. Certification path with sequencing and timeline
6. Existing credential relevance assessment
7. Total investment summary (time, cost)
