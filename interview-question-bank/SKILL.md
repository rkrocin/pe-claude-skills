---
name: interview-question-bank
description: >
  Generate structured interview question sets with evaluation rubrics for technical and leadership
  hiring. Use this skill whenever the user wants to build an interview loop, create interview
  questions for a specific role, design a hiring rubric, prepare behavioral or technical interview
  questions, evaluate candidates for engineering positions, or structure a debrief scorecard.
  Also trigger when the user mentions hiring, interviewing, candidate evaluation, interview panels,
  hiring loops, or screening criteria for engineering, platform, infrastructure, security, DevOps,
  SRE, or leadership roles. Supports both individual contributor and management-level positions.
---

# Technical Interview Question Bank

Generate structured interview question sets with evaluation rubrics, scoring criteria, and debrief frameworks for technical and leadership hiring.

## What This Skill Does

Takes a job description or role summary and generates:

1. **Interview Loop Design** with recommended stages, interviewers, and focus areas
2. **Question Sets** organized by competency with follow-up probes
3. **Evaluation Rubrics** with scoring criteria at each level (strong no hire through strong hire)
4. **Debrief Scorecard** for structured candidate comparison
5. **Red Flags and Green Flags** specific to the role

## Gathering Inputs

Collect these before generating questions. Adapt based on what the user provides.

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| Role title | Yes | - | e.g., "Director of Platform Engineering" |
| Role level | Recommended | Mid-Senior IC | IC vs. Manager vs. Director vs. VP |
| Job description | Recommended | - | Full JD or key responsibilities |
| Team context | Helpful | - | Team size, tech stack, org stage |
| Interview stage | Optional | Full loop | Which stage(s) to generate for |
| Competencies to assess | Optional | Derived from JD | Specific areas to focus on |
| Interview format | Optional | 60-minute sessions | Duration and format preferences |

If the user pastes a JD and says "build me an interview loop for this," extract all parameters from the JD.

## Interview Loop Design

### Standard Engineering Loop (IC)

| Stage | Duration | Focus | Interviewer |
|-------|----------|-------|-------------|
| Phone Screen | 30-45 min | Technical baseline, communication, motivation | Recruiter + hiring manager |
| Technical Deep Dive | 60 min | Domain expertise, problem-solving, system design | Senior IC or architect |
| System Design | 60 min | Architecture thinking, tradeoff analysis, scalability | Staff+ engineer or EM |
| Coding / Hands-on | 60 min | Implementation skill, code quality, debugging | IC peer |
| Behavioral / Culture | 45-60 min | Collaboration, conflict resolution, growth mindset | Cross-functional partner |

### Engineering Manager / Director Loop

| Stage | Duration | Focus | Interviewer |
|-------|----------|-------|-------------|
| Hiring Manager Screen | 45 min | Leadership philosophy, technical depth, career narrative | Hiring manager |
| Technical Leadership | 60 min | Architecture decisions, technical strategy, platform thinking | VP/Director peer |
| People & Org Design | 60 min | Team building, coaching, conflict resolution, org structure | HR partner + Director peer |
| Cross-functional | 60 min | Stakeholder management, communication, influence | Product/business partner |
| Executive Presence | 45 min | Strategic thinking, executive communication, vision | VP or C-level |

### Principles for Loop Design

- Each stage should assess distinct competencies with minimal overlap
- At least one stage should include a hands-on or scenario-based component (not just Q&A)
- Include at least one cross-functional interviewer to assess collaboration outside the immediate domain
- For leadership roles, at least one stage should test downward leadership (coaching, developing people) and one should test upward communication (executive presence, stakeholder management)
- Total interview time should not exceed 4-5 hours for IC roles or 5-6 hours for leadership roles

## Question Generation

### Question Structure

Every question follows this format:

```
### [Competency]: [Question Title]

**Question**: [The question as stated to the candidate]

**What this assesses**: [What capability or trait you are evaluating]

**Follow-up probes**:
- [Probe 1: dig deeper into a specific aspect]
- [Probe 2: test edge case thinking or tradeoff awareness]
- [Probe 3: explore self-awareness or lessons learned]

**Evaluation rubric**:
| Rating | Signal |
|--------|--------|
| Strong Hire | [What a strong answer looks like] |
| Hire | [What a good answer looks like] |
| Lean No Hire | [What a weak answer looks like] |
| Strong No Hire | [What a disqualifying answer looks like] |
```

### Question Categories

Load the appropriate reference file(s) based on the role:

| Category | File | Use When |
|----------|------|----------|
| Platform & Infrastructure | `references/platform-infra.md` | Platform engineering, cloud, infrastructure, DevOps, SRE roles |
| Security & Compliance | `references/security-compliance.md` | Security engineering, GRC, compliance-adjacent roles |
| Engineering Leadership | `references/engineering-leadership.md` | EM, Director, VP roles with people management responsibilities |
| Behavioral & Culture | `references/behavioral.md` | All roles (behavioral questions apply universally) |

Most roles need questions from multiple categories. A Director of Platform Engineering needs questions from platform-infra, engineering-leadership, AND behavioral.

### Question Design Principles

**Ask about their work, not hypotheticals.** "Tell me about a time you..." produces more reliable signal than "What would you do if..." People describe what they actually did, not what they think you want to hear.

**Follow-ups reveal depth.** The initial question is a prompt. The follow-ups are where real assessment happens. Push for specifics: numbers, timelines, who was involved, what went wrong, what they would change.

**Calibrate to the level.** A Senior Engineer describing a system design should discuss tradeoffs and scalability. A Director describing the same should discuss organizational alignment, team capability, and business impact. Same topic, different depth.

**Avoid trivia.** Questions that test memorized facts ("What port does HTTPS use?") reveal nothing about capability. Questions that test judgment ("How would you approach securing inter-service communication in a zero-trust model?") reveal thinking.

**Test for learning, not just knowledge.** "What is the most significant technical mistake you made in the last two years, and what did you change as a result?" reveals more than any knowledge question.

## Evaluation Rubric Design

### Scoring Scale

Use a 4-point scale to force a decision (no middle option):

| Score | Label | Meaning |
|-------|-------|---------|
| 4 | Strong Hire | Exceeds the bar. Would raise the team's capability. Clear, specific examples with depth. |
| 3 | Hire | Meets the bar. Solid answers with reasonable depth. Some areas could be stronger. |
| 2 | Lean No Hire | Below the bar. Vague answers, lacks depth, significant gaps in expected competencies. |
| 1 | Strong No Hire | Clearly below the bar. Fundamental gaps, concerning signals, or misalignment with role. |

### Rubric Principles

- Define what "good" looks like BEFORE interviewing, not after
- Rubrics should be specific to the role level (what is "strong hire" for a Senior Engineer is different from a Director)
- Each competency gets its own score. Do not average across competencies; look for patterns.
- A single "Strong No Hire" in a critical competency (e.g., technical depth for an IC, people leadership for a Director) should carry significant weight regardless of other scores

### Level-Specific Calibration

**IC (Senior / Staff)**:
- Strong Hire: Demonstrates depth AND breadth. Can explain tradeoffs from experience. Has opinions formed through practice, not theory. Identifies edge cases and failure modes without prompting.
- Hire: Solid technical depth in core area. Needs prompting on some tradeoffs but arrives at good answers. Clear communication.
- Lean No Hire: Surface-level answers. Describes what they did but not why. Cannot articulate tradeoffs or alternative approaches.
- Strong No Hire: Fundamental technical gaps for the stated level. Cannot explain their own past work in depth.

**Manager / Director**:
- Strong Hire: Demonstrates leadership through others, not just personal contribution. Has built teams, not just managed them. Can articulate organizational strategy and connect it to business outcomes. Self-aware about mistakes and growth.
- Hire: Solid people management track record. Can describe team development and org challenges with specifics. Technical depth sufficient to earn credibility with the team.
- Lean No Hire: Describes management activities (1:1s, reviews) but not outcomes. Cannot articulate how they developed people or shaped culture. Technical depth is thin.
- Strong No Hire: Leadership philosophy is command-and-control or cannot be articulated. Cannot describe team development. Takes credit for team achievements without acknowledging others.

## Debrief Scorecard

Generate a structured debrief template:

```
## Candidate Debrief: [Candidate Name]
**Role**: [Title]
**Date**: [Date]

### Interviewer Scores

| Competency | Interviewer | Score (1-4) | Key Signal |
|-----------|-------------|-------------|------------|
| Technical Depth | [Name] | | |
| System Design | [Name] | | |
| Leadership / People | [Name] | | |
| Behavioral / Culture | [Name] | | |
| Cross-functional | [Name] | | |

### Green Flags
- [Positive signals observed across interviews]

### Red Flags
- [Concerning signals observed across interviews]

### Open Questions
- [Anything that needs clarification or reference check verification]

### Recommendation
[ ] Strong Hire  [ ] Hire  [ ] Lean No Hire  [ ] Strong No Hire

**Rationale**: [2-3 sentence summary of the hiring decision rationale]
```

## Red Flags and Green Flags

Generate role-specific flags to help interviewers calibrate.

### Universal Green Flags
- Takes ownership of failures, shares credit for successes
- Asks clarifying questions before jumping to answers
- Can explain complex topics simply
- Demonstrates intellectual curiosity and continuous learning
- Gives specific examples with concrete details (numbers, timelines, outcomes)

### Universal Red Flags
- Cannot describe their own work in detail (may not have done what they claim)
- Blames others for failures without self-reflection
- Cannot name something they would do differently
- Answers are vague or theoretical when asked for specifics
- Dismissive of entire technology categories or approaches without nuance

## Edge Cases

- **Internal candidates**: Modify questions to avoid asking about information you already know. Focus on growth areas and vision for the new role rather than re-validating current capabilities.
- **Career transitioners**: Assess transferable skills more heavily than domain-specific experience. Emphasize learning trajectory and problem-solving approach.
- **Very senior candidates (VP+)**: Reduce technical trivia entirely. Focus on strategic thinking, organizational design, executive communication, and track record of building high-performing organizations.
- **Remote interviews**: Note that virtual format may disadvantage candidates with less polished video presence. Focus evaluation on substance of answers, not presentation polish.
- **Panel interviews**: Structure so each panelist owns specific questions. Avoid free-for-all questioning which disadvantages introverted candidates.

## Output

Generate the question bank as a markdown document organized by interview stage. Include the evaluation rubric inline with each question for interviewer convenience.
