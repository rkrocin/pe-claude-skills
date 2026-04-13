# Architecture Decision Record Writer

A [Claude Skill](https://docs.anthropic.com/) that generates well-structured Architecture Decision Records from technical decision context, including tradeoff analysis, weighted evaluation matrices, and consequence mapping.

## What It Does

Describe a technical decision (made or pending) and it generates:

- **Complete ADR** with context, options analysis, decision rationale, and consequences
- **Evaluation Matrix** with weighted scoring when comparing multiple options
- **Consequence Mapping** separating positive outcomes, negative tradeoffs, and conditional risks
- **Follow-up Actions** with owners and targets

## Why

Most teams know they should write ADRs but don't, because the blank page is intimidating and the format feels bureaucratic. This skill reduces the friction to zero: describe your decision in natural language and get a well-structured ADR back. The result documents reasoning that would otherwise live only in Slack threads, meeting notes, and the memories of people who may not be on the team in 18 months.

## Usage

### With Claude Desktop or Claude.ai

Install the skill, then describe your decision:

```
We decided to use SQS instead of Kafka for our payment service messaging 
because the team has no Kafka experience and we can't afford the operational 
overhead. We need PCI compliance and at-least-once delivery. Write an ADR.
```

Or describe a decision you haven't made yet:

```
We need to choose a developer portal framework. Considering Backstage, Port, 
and building custom. We have 4 frontend engineers and 500+ developers to serve. 
Help me evaluate and write a decision-pending ADR.
```

### Formats

| Format | When to Use |
|--------|-------------|
| Standard | Default. Consequential decisions affecting multiple teams, with tradeoff analysis |
| Lightweight | Straightforward decisions with limited options and easy reversibility |
| Decision Pending | Options under evaluation, emphasis on comparison matrix and recommendation |

## Sample ADRs

The `assets/` directory contains four sample ADRs demonstrating different scenarios:

| File | Scenario |
|------|----------|
| `sample-adr-standard.md` | Full-weight ADR: SQS vs. Kafka for payment messaging with evaluation matrix |
| `sample-adr-lightweight.md` | Compact ADR: selecting a Python logging library |
| `sample-adr-pending.md` | Decision pending: evaluating developer portal frameworks (Backstage vs. Port vs. custom) |
| `sample-adr-superseding.md` | Superseding ADR: migrating Jenkins to GitHub Actions, referencing the original decision |

## Writing Principles

The skill follows these principles when generating ADRs:

**Context explains the problem, not the solution.** A reader should understand WHY before learning WHAT.

**Every option gets a fair hearing.** Even rejected options are described with genuine strengths. If an option has no strengths, it was never a real contender and should not be in the ADR.

**Decisions are stated directly.** The first sentence of the Decision section names the choice. No burying the answer in paragraphs of justification.

**Consequences are honest.** Positive, negative, and risks are separated. Every decision involves tradeoffs; pretending otherwise undermines credibility. Technical debt introduced by the decision is documented explicitly.

**Written for the future.** The audience is an engineer in 18 months who has no context on why the decision was made, encountering it when something breaks or needs to change.

## Evaluation Matrix

For decisions with 3+ options, the skill generates a weighted evaluation matrix:

| Criteria (Weight) | Option A | Option B | Option C |
|--------------------|----------|----------|----------|
| Performance (30%) | 4/5 | 3/5 | 5/5 |
| Operational complexity (25%) | 3/5 | 5/5 | 2/5 |
| Team familiarity (20%) | 5/5 | 4/5 | 2/5 |
| Cost (15%) | 3/5 | 4/5 | 3/5 |
| Compliance alignment (10%) | 4/5 | 3/5 | 5/5 |
| **Weighted Score** | **3.75** | **3.95** | **3.15** |

Criteria and weights are selected based on the stated constraints. If compliance is non-negotiable, it gets high weight. If cost is secondary to reliability, the weights reflect that.

## Skill Structure

```
adr-writer/
├── SKILL.md                          # Skill definition and writing principles
├── README.md                         # This file
├── references/
│   ├── adr-format-standard.md        # Full-weight ADR template and guidance
│   └── adr-format-lightweight.md     # Compact ADR template and guidance
└── assets/
    ├── sample-adr-standard.md        # SQS vs. Kafka decision
    ├── sample-adr-lightweight.md     # Logging library selection
    ├── sample-adr-pending.md         # Developer portal evaluation
    └── sample-adr-superseding.md     # Jenkins to GitHub Actions migration
```

## License

MIT
