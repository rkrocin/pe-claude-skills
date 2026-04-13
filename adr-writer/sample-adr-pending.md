# ADR-011: Select Internal Developer Portal Framework

## Status

Proposed

## Date

2026-03-01

## Context

The platform engineering team is building an internal developer portal to serve as the front door to the IDP. The portal needs to aggregate service catalogs, documentation, Golden Path templates, API references, and platform health dashboards into a unified developer experience for 500+ engineers across 40 teams.

Currently, these resources are scattered across Confluence, GitHub wikis, SharePoint, and tribal knowledge. Developer surveys show that engineers spend an average of 45 minutes per day searching for platform information, and new hire onboarding takes 3+ weeks before engineers can make their first production deployment.

The portal must integrate with our existing SSO (Okta), GitHub, PagerDuty, and AWS infrastructure. It needs to support custom plugins for internal tooling that is specific to our organization. The platform team has 4 frontend-capable engineers who will build and maintain the portal.

## Evaluation Criteria

| Criterion | Weight | Rationale |
|-----------|--------|-----------|
| Plugin ecosystem and extensibility | 30% | Must integrate with internal tools and custom workflows |
| Operational complexity | 25% | Small team, cannot afford high maintenance burden |
| Community and longevity | 20% | Betting on a framework that will be maintained long-term |
| Customization flexibility | 15% | Portal needs to reflect our platform's specific patterns |
| Time to initial deployment | 10% | Leadership wants visible progress within one quarter |

## Options Analysis

### Option 1: Backstage (Spotify)

Open-source developer portal framework originally built at Spotify, now a CNCF Incubating project. Plugin-based architecture with a large community ecosystem.

**Strengths:**
- Largest plugin ecosystem (200+ community plugins)
- CNCF backing provides confidence in longevity
- Software catalog is a first-class concept with well-defined entity model
- TechDocs integration renders markdown documentation alongside service metadata
- Active community with regular releases and enterprise adopters (Expedia, HP, Netflix)

**Weaknesses:**
- Significant operational complexity: requires PostgreSQL, Node.js backend, React frontend, and ongoing dependency management
- Upgrade path can be painful: breaking changes between versions require manual migration
- Plugin quality is inconsistent: community plugins vary from production-ready to proof-of-concept
- React/TypeScript expertise required for custom plugin development
- Initial setup and configuration is 4-6 weeks to production-ready state

**Scoring:**
- Plugin ecosystem: 5/5
- Operational complexity: 2/5
- Community and longevity: 5/5
- Customization flexibility: 4/5
- Time to initial deployment: 2/5

**Weighted Score: 3.55**

### Option 2: Port (getport.io)

SaaS developer portal with a no-code/low-code configuration model. Catalog, scorecards, and self-service actions defined through UI or API.

**Strengths:**
- Zero infrastructure to operate: fully managed SaaS
- Configuration-driven: catalog, scorecards, and actions defined through UI without code
- Fast time to value: initial deployment in 1-2 weeks
- Built-in scorecards for production readiness and compliance tracking
- Self-service actions with approval workflows out of the box

**Weaknesses:**
- Limited customization: UI and workflows are constrained to Port's configuration model
- Vendor lock-in: catalog data and configuration are not portable
- Cost scales with engineer count ($$$$ at 500+ engineers)
- Custom integrations limited to Port's API and webhook model
- Less control over data residency and access patterns (relevant for regulated environments)

**Scoring:**
- Plugin ecosystem: 3/5
- Operational complexity: 5/5
- Community and longevity: 3/5
- Customization flexibility: 2/5
- Time to initial deployment: 5/5

**Weighted Score: 3.55**

### Option 3: Custom Build (React + API)

Build a custom portal using React frontend with a backend API that aggregates data from GitHub, PagerDuty, AWS, and internal systems.

**Strengths:**
- Complete control over UX, data model, and integrations
- No vendor dependency or framework upgrade burden
- Can be tailored exactly to organizational patterns and workflows
- Team builds deep ownership and understanding of the portal internals

**Weaknesses:**
- Highest initial development effort: 3-6 months to reach feature parity with Backstage or Port
- Ongoing maintenance burden falls entirely on the platform team
- Every integration must be built from scratch
- Risk of becoming an internal product that competes for engineering time with platform capabilities
- No community ecosystem to leverage

**Scoring:**
- Plugin ecosystem: 1/5
- Operational complexity: 3/5
- Community and longevity: 2/5
- Customization flexibility: 5/5
- Time to initial deployment: 1/5

**Weighted Score: 2.35**

## Summary Matrix

| Criteria (Weight)                  | Backstage | Port   | Custom Build |
|------------------------------------|-----------|--------|--------------|
| Plugin ecosystem (30%)             | 5/5       | 3/5    | 1/5          |
| Operational complexity (25%)       | 2/5       | 5/5    | 3/5          |
| Community and longevity (20%)      | 5/5       | 3/5    | 2/5          |
| Customization flexibility (15%)    | 4/5       | 2/5    | 5/5          |
| Time to initial deployment (10%)   | 2/5       | 5/5    | 1/5          |
| **Weighted Score**                 | **3.55**  | **3.55** | **2.35**   |

## Recommendation

Backstage and Port score identically at 3.55, but they optimize for different priorities. Backstage wins on extensibility and community, which matters most for a portal that will grow with the platform over multiple years. Port wins on operational simplicity and speed, which matters if the team needs to demonstrate value quickly with minimal infrastructure investment.

**Preliminary recommendation: Backstage**, weighted by the 30% importance of plugin ecosystem and the 20% importance of community longevity. The portal is a multi-year investment, and the extensibility ceiling matters more than time-to-first-deploy. However, the operational complexity concern (2/5) is real and should be mitigated with a dedicated CI/CD pipeline for the portal and a documented upgrade process.

If the team determines that the operational burden of Backstage is unsustainable with 4 engineers, Port becomes the recommended alternative.

## Open Questions

1. Has the team evaluated the Backstage upgrade process firsthand? A spike (1-2 days) to stand up a local instance and attempt a version upgrade would validate the operational complexity concern.
2. What is Port's pricing at 500 engineers? The per-seat cost may affect the long-term comparison.
3. Are there compliance constraints on where portal data can reside? Port is SaaS; Backstage is self-hosted. If data residency matters, this may be a deciding factor.
4. Does the team have React/TypeScript expertise for Backstage plugin development, or would this require hiring or upskilling?

## References

- [Backstage.io Documentation](https://backstage.io/docs)
- [Port Developer Portal](https://www.getport.io/)
- [CNCF Backstage Project Page](https://www.cncf.io/projects/backstage/)
