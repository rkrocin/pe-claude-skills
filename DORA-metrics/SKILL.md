---
name: dora-narrator
description: >
  Generate executive-ready narratives from DORA metrics data (Deployment Frequency, Lead Time for Changes,
  Mean Time to Recovery, Change Failure Rate). Use this skill whenever the user provides DORA metrics,
  engineering performance data, or DevOps KPIs and wants analysis, summaries, trend narratives, or
  improvement recommendations. Also trigger when the user asks for help interpreting deployment velocity,
  reliability trends, change failure patterns, or engineering productivity metrics in any format
  (JSON, CSV, or conversational). This skill converts raw engineering performance data into clear,
  actionable narratives for different audiences.
---

# DORA Metrics Narrator

Transform raw DORA metrics into executive-ready narratives, trend analysis, and actionable improvement recommendations.

## What This Skill Does

Takes DORA metrics data in JSON or CSV format and produces:

1. **Executive Summary** - A 3-5 sentence narrative suitable for CIO/CTO-level stakeholders
2. **Trend Analysis** - Quarter-over-quarter or period-over-period directional insights
3. **Risk Callouts** - Metrics moving in concerning directions or crossing thresholds
4. **Improvement Recommendations** - Specific, actionable next steps tied to the data
5. **Optional: Visualization** - A chart rendered as an HTML artifact

## Input Format

Accept DORA metrics in either JSON or CSV. The four core metrics are:

| Metric | Key | Unit | Elite Benchmark |
|--------|-----|------|-----------------|
| Deployment Frequency | `deployment_frequency` | deploys/day or deploys/week | On-demand (multiple/day) |
| Lead Time for Changes | `lead_time_hours` | hours | Less than 1 hour |
| Mean Time to Recovery | `mttr_hours` | hours | Less than 1 hour |
| Change Failure Rate | `change_failure_rate` | percentage (0-100) | 0-5% |

Each data point should include a `period` field (e.g., "Q1 2025", "2025-01", "Week 12").

### Example JSON Input

```json
{
  "team": "Platform Engineering",
  "metrics": [
    {
      "period": "Q1 2025",
      "deployment_frequency": 2.3,
      "lead_time_hours": 48,
      "mttr_hours": 4.2,
      "change_failure_rate": 12
    },
    {
      "period": "Q2 2025",
      "deployment_frequency": 3.1,
      "lead_time_hours": 36,
      "mttr_hours": 3.1,
      "change_failure_rate": 10
    },
    {
      "period": "Q3 2025",
      "deployment_frequency": 4.5,
      "lead_time_hours": 24,
      "mttr_hours": 2.5,
      "change_failure_rate": 8
    },
    {
      "period": "Q4 2025",
      "deployment_frequency": 5.8,
      "lead_time_hours": 18,
      "mttr_hours": 1.8,
      "change_failure_rate": 7
    }
  ]
}
```

## Narrative Generation

### Audience Calibration

Adjust tone and depth based on the intended audience:

**CIO / CTO / VP-level** (default):
- Lead with business impact, not technical detail
- Frame metrics as velocity, reliability, and risk posture
- Use language like "engineering throughput improved" rather than "deploys per day increased"
- Keep to 3-5 sentences for the executive summary
- Connect trends to outcomes: cost recovery, time-to-market, compliance posture

**Engineering Leadership (Director / Sr. Manager)**:
- Include specific metric values and percentage changes
- Reference DORA benchmark tiers (Elite, High, Medium, Low)
- Call out which metrics are improving vs. stalling
- Recommend concrete engineering practices (trunk-based development, feature flags, SRE adoption)

**Engineering Team**:
- Be direct and specific with numbers
- Focus on what changed and what to do next
- Reference tooling and process changes that drove results

### Narrative Structure

Follow this template for the output:

```
## Executive Summary
[3-5 sentences: overall trajectory, headline metric, business impact]

## Trend Analysis
[Period-over-period comparison for each metric with directional indicators]
[Identify which metrics are improving, stalling, or regressing]
[Note any metrics that crossed DORA benchmark tier boundaries]

## Risk Callouts
[Metrics trending in concerning directions]
[Tradeoff patterns: e.g., deployment frequency up but change failure rate also up]
[Metrics approaching tier boundaries in the wrong direction]

## Recommendations
[2-4 specific, actionable recommendations tied to the weakest metrics]
[Each recommendation should reference the data point that motivates it]
```

### DORA Benchmark Tiers

Use these thresholds when classifying team performance:

**Deployment Frequency:**
- Elite: On-demand (multiple per day)
- High: Between once per day and once per week
- Medium: Between once per week and once per month
- Low: Less than once per month

**Lead Time for Changes:**
- Elite: Less than 1 hour
- High: Between 1 day and 1 week
- Medium: Between 1 week and 1 month
- Low: More than 1 month

**Mean Time to Recovery:**
- Elite: Less than 1 hour
- High: Less than 1 day
- Medium: Between 1 day and 1 week
- Low: More than 1 month

**Change Failure Rate:**
- Elite: 0-5%
- High: 5-10%
- Medium: 10-15%
- Low: 15-25%+

### Tradeoff Detection

Watch for and call out these common patterns:

- **Velocity without stability**: Deployment frequency increasing while change failure rate also increases. The team is shipping faster but breaking more. Recommend feature flags, canary deployments, or expanded test coverage.
- **Recovery masking quality**: MTTR improving while change failure rate stays flat or increases. The team is getting better at fixing problems but not preventing them. Recommend shift-left testing and pre-production validation.
- **Bottlenecked pipeline**: Deployment frequency improving but lead time stagnant. Something in the pipeline (approvals, environment provisioning, manual gates) is throttling flow. Recommend pipeline analysis and automation of manual steps.
- **All metrics flat**: No meaningful movement in any direction. The team may have hit a local optimum or lost focus on engineering practices. Recommend a focused improvement sprint on the weakest metric.

## Visualization (Optional)

If the user asks for a chart or visual, generate an HTML artifact with a multi-line chart showing all four DORA metrics over time. Use a dual-axis layout: left axis for deployment frequency and hours-based metrics, right axis for change failure rate (percentage).

Refer to `/mnt/skills/public/frontend-design/SKILL.md` for styling guidance when building the visualization.

## Example Output

Given the sample JSON input above, the output should look approximately like this:

---

**Executive Summary**

Platform Engineering delivered strong, sustained improvement across all four DORA metrics in 2025. Deployment frequency more than doubled from 2.3 to 5.8 deploys per day, while lead time dropped 62% from 48 to 18 hours. Recovery capability improved significantly with MTTR falling to 1.8 hours, and the team reduced change failure rate from 12% to 7%, crossing from Medium into the High performance tier. This trajectory reflects a maturing platform organization that is shipping faster without sacrificing stability.

**Trend Analysis**

| Metric | Q1 2025 | Q4 2025 | Change | Tier Movement |
|--------|---------|---------|--------|---------------|
| Deployment Frequency | 2.3/day | 5.8/day | +152% | High |
| Lead Time | 48 hrs | 18 hrs | -62% | High |
| MTTR | 4.2 hrs | 1.8 hrs | -57% | High |
| Change Failure Rate | 12% | 7% | -42% | Medium to High |

All four metrics showed consistent quarter-over-quarter improvement with no reversals. The strongest acceleration was in deployment frequency (Q3 to Q4), suggesting recent investments in pipeline automation are paying off. Change failure rate improved the most slowly, which is typical when teams increase deployment velocity.

**Risk Callouts**

No metrics are trending in a concerning direction. The main area to watch is change failure rate, which at 7% is just inside the High tier boundary. If deployment frequency continues to accelerate, monitor whether CFR holds or begins to creep back toward 10%.

**Recommendations**

1. **Target Elite-tier MTTR**: At 1.8 hours, MTTR is close to the Elite threshold of 1 hour. Investing in automated rollback and improved observability could close this gap within 1-2 quarters.
2. **Protect change failure rate as velocity increases**: Implement progressive delivery (canary releases, feature flags) to maintain quality as deployment frequency pushes higher.
3. **Reduce lead time through pipeline optimization**: At 18 hours, there is likely a manual approval or environment provisioning step creating a floor. Audit the pipeline for automatable gates.

---

## Edge Cases

- **Missing metrics**: If one or more DORA metrics are absent, generate analysis for what is available and note which metrics are missing.
- **Single period**: If only one period is provided, skip trend analysis and generate a snapshot assessment against DORA benchmarks.
- **Non-standard periods**: Accept any period format (quarters, months, weeks, sprints) and label accordingly.
- **Outliers**: If a metric shows a dramatic swing (>50% change in one period), flag it explicitly and suggest investigating root cause before drawing conclusions.
