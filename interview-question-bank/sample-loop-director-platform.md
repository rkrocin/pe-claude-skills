# Interview Loop: Director, Platform Engineering
## Chicago Financial Services - 100+ Engineer Organization

### Role Summary
Director of Platform Engineering leading cloud infrastructure, internal developer platform, and DevSecOps for a regulated financial services organization. Reports to VP of Engineering. Manages 4-5 engineering managers with a total organization of 80-100 engineers. Budget ownership of $30-50M.

---

## Interview Loop Design

| Stage | Duration | Focus | Interviewer | Questions |
|-------|----------|-------|-------------|-----------|
| 1. Hiring Manager Screen | 45 min | Career narrative, leadership philosophy, technical depth | VP of Engineering | 2 questions |
| 2. Technical Leadership | 60 min | Platform architecture, IaC at scale, cloud strategy | Director/VP peer (Infrastructure or Architecture) | 3 questions |
| 3. People & Org Design | 60 min | Team building, performance management, org transformation | HR Business Partner + Director peer | 3 questions |
| 4. Security & Compliance | 60 min | DevSecOps, audit readiness, compliance architecture | CISO or Security Director | 2 questions |
| 5. Cross-Functional | 45 min | Stakeholder management, business alignment, communication | Product VP or Business Technology leader | 2 questions |

---

## Stage 1: Hiring Manager Screen (45 min)

### Career Narrative & Motivation (15 min)

**Question**: Walk me through your career arc, focusing on the decisions that brought you to platform engineering leadership. What is driving your interest in this role?

**What this assesses**: Self-awareness, career intentionality, motivation alignment with the opportunity.

**Follow-up probes**:
- What was the most pivotal career transition you made, and why?
- What drew you to platform engineering specifically (vs. application engineering, security, etc.)?
- What are you looking for in your next role that you do not have today?

**Evaluation rubric**:
| Rating | Signal |
|--------|--------|
| Strong Hire | Coherent career narrative with deliberate transitions. Can articulate what they learned at each stage and how it prepared them for this role. Motivation aligns with the actual opportunity (not a generic "looking for growth" answer). |
| Hire | Reasonable career narrative. Motivation is clear and relevant. May lack depth on specific transitions. |
| Lean No Hire | Career narrative is disjointed or opportunistic. Cannot articulate why platform engineering. Motivation does not align with the role. |
| Strong No Hire | Cannot explain their career decisions. Motivation is primarily extrinsic (title, compensation) with no connection to the work. |

---

### Leadership Philosophy (15 min)

**Question**: How would you describe your leadership philosophy, and how has it evolved over the last five years? Give me a specific example of how your philosophy showed up in a real decision.

**What this assesses**: Leadership self-awareness, evolution and growth, alignment with organizational values.

**Follow-up probes**:
- What is one thing you believed about leadership five years ago that you no longer believe?
- How do you adapt your leadership style for different team members or situations?
- What feedback have you received about your leadership that surprised you?

**Evaluation rubric**:
| Rating | Signal |
|--------|--------|
| Strong Hire | Articulates a clear philosophy grounded in specific experiences. Shows evolution over time (not a static platitude). Gives a concrete example that demonstrates the philosophy in action. Self-aware about strengths and development areas. |
| Hire | Has a reasonable leadership philosophy with some self-awareness. May be less specific about evolution or application. |
| Lean No Hire | Philosophy is generic ("servant leadership" without specifics). No evidence of evolution or self-reflection. |
| Strong No Hire | Cannot articulate a leadership philosophy, or describes a philosophy that conflicts with organizational values (e.g., command-and-control in a culture that values empowerment). |

---

## Stage 2: Technical Leadership (60 min)

### Platform Architecture at Scale (20 min)

**Question**: Walk me through how you would design an internal developer platform that serves 500+ engineers across 30 teams. What are the key components, and how do you prioritize what to build first?

*(Full rubric in references/platform-infra.md)*

---

### IaC at Enterprise Scale (20 min)

**Question**: How have you managed Terraform at enterprise scale? How do you handle module versioning, state management, and preventing drift across hundreds of resources?

*(Full rubric in references/platform-infra.md)*

---

### Cloud Cost Governance (20 min)

**Question**: You inherit a $40M annual cloud budget that has been growing 25% year-over-year with no formal governance. What do you do in the first 90 days?

*(Full rubric in references/platform-infra.md)*

---

## Stage 3: People & Org Design (60 min)

### Building Teams (20 min)

**Question**: Tell me about a team you built or significantly reshaped. What was the starting point, what did you change, and what was the outcome?

*(Full rubric in references/engineering-leadership.md)*

---

### Managing Underperformance (20 min)

**Question**: Tell me about a time you had to manage out an underperformer. How did you make the determination, and how did you handle the process?

*(Full rubric in references/engineering-leadership.md)*

---

### Organizational Transformation (20 min)

**Question**: Describe a significant organizational transformation you led or contributed to. What was the before state, what did you change, and how did you manage the transition?

*(Full rubric in references/engineering-leadership.md)*

---

## Stage 4: Security & Compliance (60 min)

### Shift-Left Security (30 min)

**Question**: How have you embedded security into the development pipeline without slowing teams down? Give me a specific example of a security control you implemented and how you managed the developer experience tradeoff.

*(Full rubric in references/platform-infra.md)*

---

### Audit Readiness (30 min)

**Question**: You have 90 days before a PCI DSS audit. Walk me through your preparation process, assuming the environment has never been audited before.

*(Full rubric in references/security-compliance.md)*

---

## Stage 5: Cross-Functional (45 min)

### Stakeholder Influence (25 min)

**Question**: Tell me about a time you had to influence a senior stakeholder to invest in a platform initiative that did not have obvious short-term ROI. How did you make the case?

*(Full rubric in references/engineering-leadership.md)*

---

### Explaining Technical Strategy (20 min)

**Question**: Explain the most complex platform initiative you have led to me as if I were a business leader who needs to understand the investment and expected return. No jargon.

*(Adapted from references/behavioral.md - Explaining Complex Topics)*

---

## Debrief Scorecard

### Candidate: _______________
**Role**: Director, Platform Engineering
**Date**: _______________

| Competency | Stage | Interviewer | Score (1-4) | Key Signal |
|-----------|-------|-------------|-------------|------------|
| Career Narrative & Motivation | 1 | | | |
| Leadership Philosophy | 1 | | | |
| Platform Architecture | 2 | | | |
| IaC at Scale | 2 | | | |
| FinOps & Cost Governance | 2 | | | |
| Team Building | 3 | | | |
| Performance Management | 3 | | | |
| Org Transformation | 3 | | | |
| DevSecOps Integration | 4 | | | |
| Audit & Compliance | 4 | | | |
| Stakeholder Influence | 5 | | | |
| Executive Communication | 5 | | | |

### Green Flags for This Role
- Has built platform teams, not just managed them
- Can connect platform investments to business outcomes with specific metrics
- Demonstrates security as embedded practice, not afterthought
- Has managed $10M+ budgets with FinOps discipline
- Shows evidence of developing people who advanced to leadership roles
- Comfortable with regulated environment constraints

### Red Flags for This Role
- Platform experience limited to tooling selection, no organizational or cultural transformation
- Cannot describe managing a $10M+ budget or making cost tradeoffs
- Security is described as someone else's domain
- People development examples are generic (mentoring, 1:1s) without specific outcomes
- Cannot articulate a technical strategy connected to business outcomes
- Adversarial toward compliance or audit processes

### Recommendation
[ ] Strong Hire  [ ] Hire  [ ] Lean No Hire  [ ] Strong No Hire

**Rationale**: _______________
