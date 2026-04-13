---
name: cert-study-planner
description: >
  Generate structured study plans for professional IT and engineering certifications. Use this skill
  whenever the user wants to prepare for a certification exam, build a study schedule, identify study
  resources, plan a certification path, or assess readiness for an exam. Also trigger when the user
  mentions specific certifications (AWS, CISSP, CKA, Terraform, FinOps, CISM, CRISC, PMP, etc.),
  asks about exam preparation strategies, wants to compare certifications, or needs help prioritizing
  which certifications to pursue. Supports individual exam planning and multi-certification path
  sequencing.
---

# Certification Study Planner

Generate structured study plans for professional certifications with topic breakdown, resource recommendations, milestone scheduling, and readiness assessment checkpoints.

## What This Skill Does

Takes a target certification, available study time, and experience level, then generates:

1. **Study Plan** with weekly schedule, topic sequencing, and time allocation
2. **Topic Breakdown** mapping exam domains to study priorities based on weight and difficulty
3. **Resource Recommendations** organized by learning style (reading, video, hands-on)
4. **Milestone Checkpoints** with practice test scheduling and readiness criteria
5. **Certification Path Advice** when the user is choosing between certifications or planning a sequence

## Gathering Inputs

Collect these parameters before generating a plan. Use reasonable defaults for anything unspecified.

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| Target certification | Yes | - | Which exam (e.g., "AWS Solutions Architect Professional") |
| Exam date | Recommended | 8 weeks from today | When the user plans to take the exam |
| Study hours per week | Recommended | 10 hours | Available weekly study time |
| Experience level | Helpful | Intermediate | Familiarity with the domain (Beginner, Intermediate, Advanced) |
| Learning style | Optional | Mixed | Preference: reading, video, hands-on labs, or mixed |
| Prior certifications | Optional | None | Related certs already held (affects prerequisite coverage) |
| Weak areas | Optional | None | Self-identified topics needing extra focus |

If the user says something like "I want to get my CISSP, I have about 6 weeks and can study 15 hours a week, I'm strong on networking but weak on software security," extract all parameters from that statement.

## Certification Reference Files

Detailed exam profiles for common certifications are in `references/`. Load the relevant file before generating a plan.

| Category | File | Certifications Covered |
|----------|------|----------------------|
| AWS | `references/aws-certs.md` | Solutions Architect (Associate/Professional), Developer, SysOps, Security Specialty, ML Specialty, Data Engineer, GenAI Developer |
| Cybersecurity | `references/security-certs.md` | CISSP, ISSAP, ISSEP, CCSP, CISM, CRISC, CGEIT, CSSLP, GSLC, CompTIA Security+ |
| Cloud & Platform | `references/platform-certs.md` | CKA, CKAD, CKS, Terraform Associate, FinOps Practitioner, FinOps Engineer |
| AI/ML | `references/ai-certs.md` | AWS GenAI Developer Professional, AWS ML Specialty, AWS ML Engineer, AAISM, Google Professional ML Engineer |

If the target certification is not covered in the reference files, generate a plan based on publicly available exam guide information and note that the domain breakdown is approximate.

## Study Plan Generation

### Step 1: Assess Scope

Calculate total available study hours:
```
total_hours = weeks_until_exam * hours_per_week
```

Estimate required study hours based on certification difficulty and experience level:

| Difficulty Tier | Beginner | Intermediate | Advanced |
|----------------|----------|--------------|----------|
| Associate/Foundation | 60-80 hrs | 40-60 hrs | 20-30 hrs |
| Professional/Specialty | 100-140 hrs | 70-100 hrs | 40-60 hrs |
| Expert/Master (CISSP, ISSAP) | 150-200 hrs | 100-140 hrs | 60-80 hrs |

If total available hours are less than 70% of estimated required hours, flag this and recommend either extending the timeline or increasing weekly hours. Do not tell the user it is impossible, but be honest about the risk.

### Step 2: Prioritize Domains

Using the exam domain weights from the reference file, prioritize study time:

1. **High priority**: Domains with the highest exam weight AND where the user has the least experience
2. **Medium priority**: High-weight domains where the user has moderate experience, or low-weight domains where the user has no experience
3. **Low priority**: Domains where the user has strong experience regardless of weight

Allocate study time proportionally, with a bias toward high-priority domains:
- High priority domains: 40-50% of total time
- Medium priority domains: 30-35% of total time
- Low priority domains: 15-20% of total time
- Practice tests and review: reserve 15-20% of total time for the final phase

### Step 3: Sequence Topics

Follow this general sequencing strategy:

**Weeks 1-2 (Foundation)**: Start with foundational domains that other topics build on. For cloud certs, this is usually core services and architecture principles. For security certs, this is usually security fundamentals and risk management.

**Weeks 3-5 (Deep Dive)**: Cover the highest-weight domains in depth. This is where the bulk of study time goes. Interleave reading/video with hands-on practice.

**Weeks 6-7 (Breadth + Gaps)**: Cover remaining domains, fill identified gaps, and begin practice exams. Use practice test results to redirect remaining study time.

**Final Week (Review + Readiness)**: Full-length practice exams, review weak areas identified in practice tests, light review of all domains. No new material in the final 3 days.

Adjust this framework based on actual weeks available. For shorter timelines (3-4 weeks), compress the foundation phase and start practice tests earlier. For longer timelines (12+ weeks), add a second deep-dive cycle and more practice test iterations.

### Step 4: Build Weekly Schedule

Generate a week-by-week plan with:

```
## Week N: [Theme]
**Focus**: [Primary domain(s)]
**Hours**: [Target hours for the week]

| Day | Activity | Duration | Resources |
|-----|----------|----------|-----------|
| Mon | [Topic] | 1.5 hrs | [Specific resource] |
| Wed | [Topic] | 1.5 hrs | [Specific resource] |
| Sat | [Hands-on lab or practice] | 2 hrs | [Specific resource] |

**Milestone**: [What the user should be able to do by end of week]
```

Distribute study sessions across available days. Avoid scheduling more than 3 hours in a single session (diminishing returns). Recommend spacing study across at least 3-4 days per week for retention.

### Step 5: Set Milestones and Checkpoints

Include these checkpoints in every plan:

**25% checkpoint** (after ~25% of study time):
- Complete a domain-specific mini quiz (20-30 questions) on the first domains studied
- Target: 60% or higher indicates adequate foundation
- If below 60%: revisit foundational material before moving forward

**50% checkpoint** (midpoint):
- First full-length practice exam
- Target: 55-65% (this is normal at the midpoint)
- Use results to identify weak domains for remaining study time

**75% checkpoint** (3/4 through):
- Second full-length practice exam
- Target: 70-75%
- If below 65%: consider extending the timeline
- Redirect remaining study time to weakest domains

**Final readiness check** (2-3 days before exam):
- Third full-length practice exam
- Target: 80%+ (most certification passing scores are 70-75%)
- If consistently above 75% on practice exams: ready to sit
- If below 70%: recommend postponing if possible

### Step 6: Resource Recommendations

Organize resources by type:

**Primary study material** (pick one):
- Official study guide or course
- Well-regarded third-party course (e.g., A Cloud Guru, Stephane Maarek for AWS, Destination Certification for CISSP)

**Supplementary resources**:
- Official documentation (free, always current)
- Video courses for visual learners
- Hands-on labs for practical certifications

**Practice tests** (essential for every certification):
- Official practice exam from the certifying body
- Third-party question banks (e.g., Tutorials Dojo for AWS, Boson for CISSP)
- Note: practice tests are not just for assessment; reviewing explanations for wrong answers is one of the highest-value study activities

**Community resources**:
- Reddit exam-specific subreddits (r/AWSCertifications, r/cissp, etc.)
- Certification-specific Discord servers or study groups
- Exam experience reports from recent test-takers

## Certification Path Planning

When the user asks which certification to pursue or wants to sequence multiple certifications:

### Single Certification Selection

Help the user choose based on:
- **Career goal alignment**: Which cert is most relevant to their target role?
- **Current experience**: Which cert builds on what they already know?
- **Market demand**: Which cert is most valued by employers in their target market?
- **Prerequisite chain**: Does the cert require prior certifications or experience?

### Multi-Certification Sequencing

When planning a sequence of certifications:
- Start with foundational certs that make subsequent ones easier
- Group related certs to maximize knowledge overlap (e.g., AWS SA Associate before Professional)
- Space exams 4-6 weeks apart to allow for focused preparation without burnout
- Consider certification renewal timelines when sequencing

## Edge Cases

- **Very short timeline (< 3 weeks)**: Acknowledge the constraint honestly. Focus exclusively on high-weight domains and practice tests. Skip low-weight domains entirely. Recommend the user assess whether postponing is an option.
- **Very long timeline (> 16 weeks)**: Risk of losing early material. Build in periodic review cycles and additional practice test rounds. Consider splitting into two phases with a break.
- **Multiple certs simultaneously**: Generally discourage unless the certs are closely related (e.g., AWS Developer + SysOps). Recommend sequential preparation.
- **Expired or changing exam versions**: If an exam version is changing soon, note the transition date and recommend which version to target based on the user's timeline.
- **No hands-on experience**: For practical certifications (AWS, CKA, Terraform), hands-on practice is non-negotiable. Allocate at least 30% of study time to labs and recommend a sandbox environment.

## Output Format

Generate the study plan as a structured document with:

1. Plan summary (target cert, timeline, total hours, readiness assessment)
2. Domain priority analysis (table showing domains, weights, user experience, priority)
3. Week-by-week schedule with daily activities
4. Milestone checkpoints with target scores
5. Resource list organized by type
6. Exam day preparation tips specific to the certification format
