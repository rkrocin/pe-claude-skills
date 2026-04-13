# DORA Metrics Narrator

A [Claude Skill](https://docs.anthropic.com/) that transforms raw DORA metrics into executive-ready narratives, trend analysis, and actionable improvement recommendations.

## What It Does

Feed it DORA metrics (Deployment Frequency, Lead Time for Changes, MTTR, Change Failure Rate) as JSON or CSV, and it generates:

- **Executive Summary** calibrated for CIO/CTO-level stakeholders
- **Trend Analysis** with period-over-period comparison and DORA tier classification
- **Risk Callouts** including tradeoff detection (e.g., velocity increasing but stability degrading)
- **Improvement Recommendations** tied to specific data points
- **Optional Visualization** as an interactive HTML chart

## Why

Engineering leaders spend hours each cycle translating raw DORA data into narratives for leadership reviews, board decks, and quarterly business reviews. This skill eliminates that toil by generating consistent, benchmark-aware analysis directly from the data.

It also detects common antipatterns that are easy to miss in raw numbers, like teams that are shipping faster but breaking more, or teams whose recovery speed is masking a quality problem.

## Usage

### With Claude Desktop or Claude.ai

Install the skill, then prompt Claude with your DORA data:

```
Here are our DORA metrics for the last four quarters. Generate an executive summary 
and recommendations.

{
  "team": "Platform Engineering",
  "metrics": [
    {"period": "Q1 2025", "deployment_frequency": 2.3, "lead_time_hours": 48, "mttr_hours": 4.2, "change_failure_rate": 12},
    {"period": "Q2 2025", "deployment_frequency": 3.1, "lead_time_hours": 36, "mttr_hours": 3.1, "change_failure_rate": 10},
    {"period": "Q3 2025", "deployment_frequency": 4.5, "lead_time_hours": 24, "mttr_hours": 2.5, "change_failure_rate": 8},
    {"period": "Q4 2025", "deployment_frequency": 5.8, "lead_time_hours": 18, "mttr_hours": 1.8, "change_failure_rate": 7}
  ]
}
```

### Audience Targeting

You can specify the audience to adjust tone and depth:

- `"Write this for a CIO audience"` - Business impact focus, minimal technical detail
- `"Write this for engineering directors"` - Includes DORA tier classifications and practice recommendations
- `"Write this for the engineering team"` - Direct, numbers-forward, action-oriented

## Sample Datasets

The `assets/` directory contains sample datasets for testing:

| File | Scenario |
|------|----------|
| `sample-improving.json` | Healthy improvement across all four metrics over four quarters |
| `sample-velocity-tradeoff.json` | Team shipping faster but change failure rate climbing (antipattern) |
| `sample-snapshot.json` | Single-period snapshot for benchmark-only assessment |

## DORA Benchmark Tiers

The skill classifies metrics against the standard DORA benchmark tiers from the Accelerate State of DevOps research:

| Metric | Elite | High | Medium | Low |
|--------|-------|------|--------|-----|
| Deployment Frequency | Multiple/day | Daily to weekly | Weekly to monthly | < Monthly |
| Lead Time for Changes | < 1 hour | 1 day to 1 week | 1 week to 1 month | > 1 month |
| MTTR | < 1 hour | < 1 day | 1 day to 1 week | > 1 month |
| Change Failure Rate | 0-5% | 5-10% | 10-15% | 15-25%+ |

## Tradeoff Detection

The skill watches for and calls out common patterns:

- **Velocity without stability** - Deployment frequency up, change failure rate also up
- **Recovery masking quality** - MTTR improving but change failure rate flat or rising
- **Bottlenecked pipeline** - Deployment frequency up but lead time stagnant
- **Plateau** - All metrics flat across periods

## Skill Structure

```
dora-narrator/
├── SKILL.md              # Skill definition and instructions
├── README.md             # This file
└── assets/
    ├── sample-improving.json
    ├── sample-velocity-tradeoff.json
    └── sample-snapshot.json
```

## License

MIT
