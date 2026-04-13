---
name: adr-writer
description: >
  Generate Architecture Decision Records (ADRs) from technical decision context. Use this skill whenever
  the user wants to document an architecture decision, technology choice, design tradeoff, or technical
  strategy. Also trigger when the user asks about ADR format, how to write an ADR, how to document a
  technical decision, or when they describe a decision they've made (or need to make) about infrastructure,
  frameworks, data stores, service boundaries, deployment strategies, authentication approaches, or any
  other architectural concern. Supports multiple ADR formats (standard, lightweight, Nygard) and can
  generate decision matrices for options under evaluation.
---

# Architecture Decision Record Writer

Generate well-structured Architecture Decision Records from technical decision context, including tradeoff analysis, options evaluation, and consequence mapping.

## What This Skill Does

Takes a description of a technical decision (made or pending) and generates:

1. **Complete ADR** following a structured format with title, status, context, decision, consequences, and tradeoffs
2. **Options Analysis** comparing alternatives with a weighted evaluation matrix when multiple options are under consideration
3. **Consequence Mapping** identifying positive outcomes, risks, and technical debt implications
4. **Follow-up Actions** documenting what needs to happen to implement or monitor the decision

## When to Generate an ADR

ADRs are appropriate when a decision:

- Is difficult to reverse once implemented
- Affects multiple teams or services
- Involves meaningful tradeoffs between competing priorities
- Establishes a pattern or precedent others will follow
- Would be confusing to a future engineer without documented rationale
- Involves significant cost, security, compliance, or operational implications

ADRs are NOT needed for routine implementation choices, bug fixes, library version bumps, or decisions that are trivially reversible.

## Gathering Context

Before generating, collect these inputs from the user. Not all are required; adapt based on what the user provides.

| Input | Required | Description |
|-------|----------|-------------|
| Decision topic | Yes | What is being decided (e.g., "primary data store for user service") |
| Context / problem | Yes | Why this decision needs to be made now |
| Options considered | Recommended | 2-4 alternatives that were evaluated |
| Decision made | If decided | Which option was chosen (skip if the user wants help deciding) |
| Constraints | Helpful | Non-negotiable requirements (compliance, latency, budget, team skills) |
| Stakeholders | Optional | Who is affected by or contributed to this decision |
| Prior decisions | Optional | Related ADRs or past decisions this builds on |

If the user provides a natural language description like "we decided to use Kafka instead of SQS because we need replay and our team already knows it," extract all available context from that statement rather than asking for each field.

## ADR Format

### Standard Format (Default)

Use this format unless the user requests otherwise. Read `references/adr-format-standard.md` for the full template.

```
# ADR-NNN: [Decision Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-NNN]

## Date
[Date of decision]

## Context
[Why this decision is needed. What forces are at play. What constraints exist.]

## Options Considered

### Option 1: [Name]
[Description, strengths, weaknesses]

### Option 2: [Name]
[Description, strengths, weaknesses]

## Decision
[Which option was chosen and the core reasoning in 2-3 sentences]

## Consequences

### Positive
[What improves as a result of this decision]

### Negative
[What gets harder, more expensive, or riskier]

### Risks
[What could go wrong and under what conditions]

## Follow-up Actions
[Specific next steps to implement or monitor this decision]

## References
[Links to relevant documentation, benchmarks, RFCs]
```

### Lightweight Format

For less consequential decisions or teams that prefer brevity. Read `references/adr-format-lightweight.md`.

```
# ADR-NNN: [Decision Title]
**Status**: [Accepted]  **Date**: [Date]

**Context**: [2-3 sentences]

**Decision**: [1-2 sentences]

**Consequences**: [Bullet list of key impacts]
```

### Decision Pending Format

When the user hasn't decided yet and wants help evaluating options. This format emphasizes the evaluation matrix.

```
# ADR-NNN: [Decision Title]

## Status
Proposed

## Context
[Problem statement and constraints]

## Evaluation Criteria
[Weighted criteria for comparing options]

## Options Analysis
[Detailed comparison with scoring]

## Recommendation
[Which option the analysis favors and why]

## Open Questions
[What needs to be resolved before deciding]
```

## Writing Principles

### Context Section
- Explain the problem, not the solution. A reader should understand WHY this decision matters before learning WHAT was decided.
- Include the forces at play: business drivers, technical constraints, team capabilities, timeline pressure, regulatory requirements.
- Reference prior decisions or existing architecture that this decision interacts with.
- Be specific about what triggered the decision NOW. "We need a message queue" is weaker than "Order volume grew 3x in Q4 and our synchronous processing pipeline is hitting 30-second timeouts at peak."

### Options Section
- Present each option fairly. Even the rejected options should be described with their genuine strengths.
- Every option should have at least one strength and one weakness. If an option has no strengths, it should not be in the ADR (it was never a real contender).
- Include the "do nothing" or "status quo" option when relevant. Sometimes the best decision is to not change.
- Quantify where possible: latency, cost, throughput, team ramp-up time, migration effort.

### Decision Section
- State the decision clearly in the first sentence. Do not bury the answer.
- Explain the reasoning in terms of which tradeoffs were prioritized. "We chose X because latency matters more than cost in this context" is stronger than "We chose X because it's better."
- Acknowledge what is being given up. Every decision involves tradeoffs; pretending otherwise undermines credibility.

### Consequences Section
- Separate positive consequences, negative consequences, and risks. They are different things.
- Positive: what improves, what becomes easier, what is now possible
- Negative: what gets harder, what costs more, what complexity is added. These are known, accepted downsides.
- Risks: what COULD go wrong under specific conditions. Include the conditions and potential mitigations.
- Be honest about technical debt introduced. If this decision creates future work, say so.

### Tone
- Write for a future engineer who has no context on why this decision was made. They will read this ADR in 18 months when something breaks or needs to change.
- Be direct and specific. Avoid hedge words ("might," "possibly," "it seems like") in the decision itself. Hedging belongs in the risks section.
- Do not use the ADR to advocate. By the time it is written, the decision is made (or the options are fairly presented for a pending decision). The ADR documents reasoning, not sells a conclusion.

## Options Evaluation Matrix

When comparing multiple options, generate a weighted evaluation matrix:

```
| Criteria (Weight)           | Option A | Option B | Option C |
|-----------------------------|----------|----------|----------|
| Performance (30%)           | 4/5      | 3/5      | 5/5      |
| Operational complexity (25%)| 3/5      | 5/5      | 2/5      |
| Team familiarity (20%)      | 5/5      | 4/5      | 2/5      |
| Cost (15%)                  | 3/5      | 4/5      | 3/5      |
| Compliance alignment (10%)  | 4/5      | 3/5      | 5/5      |
| **Weighted Score**          | **3.75** | **3.95** | **3.15** |
```

### Scoring Guidelines
- 5: Excellent fit, clear advantage
- 4: Good fit, minor limitations
- 3: Adequate, no strong advantage or disadvantage
- 2: Weak fit, significant limitations
- 1: Poor fit, likely disqualifying

### Criteria Selection
Choose 4-6 criteria based on the decision context. Common criteria include:

**Technical**: Performance, scalability, reliability, security, observability, data consistency
**Operational**: Operational complexity, deployment complexity, debugging/troubleshooting, disaster recovery
**Organizational**: Team familiarity, hiring/talent availability, vendor lock-in, community/ecosystem
**Business**: Cost (build + run), time to implement, compliance alignment, business continuity

Weight criteria based on what actually matters for this decision. If compliance is non-negotiable, it gets high weight. If cost is secondary to reliability, weight accordingly. The weights should reflect the stated constraints.

## Edge Cases

- **Single option**: If only one option is described, skip the evaluation matrix and focus on documenting the rationale and consequences. Note in the context why alternatives were not considered (e.g., organizational mandate, only viable option).
- **Reversing a prior decision**: If the ADR supersedes a previous decision, reference the prior ADR, explain what changed, and set the prior ADR's status to "Superseded by ADR-NNN."
- **Partial information**: If the user provides incomplete context, generate what you can and add an "Open Questions" section listing what should be resolved before finalizing.
- **Non-technical decisions**: ADRs can document process decisions (e.g., "adopt trunk-based development") or organizational decisions (e.g., "split the platform team into two squads"). Apply the same structure but adjust the criteria and consequences accordingly.
- **Multiple related decisions**: If the user describes what is really two or three decisions bundled together, suggest splitting into separate ADRs with cross-references.

## Numbering

- If the user specifies a number, use it.
- If the user has an existing ADR series, continue the sequence.
- If no context is provided, use `ADR-001` and note that the number should be updated to fit their existing sequence.

## Output

Generate the ADR as a markdown file. If the user wants a file, save it as `adr-NNN-[kebab-case-title].md`.
