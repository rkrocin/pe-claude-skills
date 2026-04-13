# Platform Product Brief: GenAI-Powered Engineering Knowledge Platform

**Author**: Platform Engineering
**Date**: March 2026
**Status**: Approved
**Sponsor**: VP of Engineering

---

## The Problem

### The Pain
Engineers spend an average of 52 minutes per day searching for internal documentation, tribal knowledge, and platform guidance across six disconnected systems (Confluence, GitHub wikis, SharePoint, Slack archives, ServiceNow knowledge base, and internal blog). A time study across 40 engineers over two weeks showed that 73% of searches ended in asking a colleague rather than finding the answer in documentation, and 31% of Slack questions in engineering channels are repeat questions that have been answered before.

### The Consequence
At a fully loaded engineering cost of $95/hour, 52 minutes of daily search time across 800 engineers represents approximately $6.2M in annual lost productivity. Beyond the direct cost, knowledge fragmentation slows onboarding (new engineers take 3.2 weeks to make their first production deployment vs. an industry benchmark of 2 weeks), increases incident resolution time (MTTR includes an average of 12 minutes of documentation searching per SEV2+ incident), and creates a dependency on senior engineers who become bottlenecks for institutional knowledge.

### The Trend
Knowledge fragmentation is accelerating. The number of internal documentation pages has grown 45% year-over-year while documentation quality scores (measured by quarterly survey) have declined 15%. The IDP scaled to 15,000+ engineers and introduced 20,000+ reusable assets, but discoverability has not kept pace with content growth. As the organization grows through acquisition, knowledge silos are multiplying rather than consolidating.

### Evidence

| Signal | Data Point | Source |
|--------|-----------|--------|
| Search time | 52 min/day average across engineering | Time study (Feb 2026, n=40) |
| Failed searches | 73% of searches end in asking a colleague | Time study observation |
| Repeat questions | 31% of Slack engineering channel questions are repeats | Slack analytics (Q4 2025) |
| Onboarding time | 3.2 weeks to first production deploy (new hires) | Engineering onboarding tracker |
| MTTR documentation overhead | 12 min average per SEV2+ incident | Incident postmortem analysis (2025) |
| Documentation NPS | -12 (declined from +8 in 2024) | Quarterly developer experience survey |

---

## Who Is Affected

### Primary Users

**Application Engineer** - Full-stack / backend developer
- Current pain: Cannot find the right Golden Path, API documentation, or configuration guidance without asking in Slack. Searches across 6 systems daily. Frequently discovers outdated documentation that wastes time.
- Frequency: 3-5 search sessions per day
- Impact: 45-60 minutes lost daily; frustration drives avoidance of platform documentation entirely

**New Hire Engineer** - First 90 days
- Current pain: No single entry point for "how do we do things here." Onboarding guide exists but links are broken and information is scattered. Relies heavily on buddy/mentor for basic questions that should be self-service.
- Frequency: 10+ search sessions per day during first month
- Impact: Extended onboarding timeline; mentor time consumed answering discoverable questions

**On-Call SRE** - During incident response
- Current pain: Runbooks exist but are not discoverable during high-pressure incidents. Searches during incidents add minutes to MTTR. Some runbooks are outdated and create confusion.
- Frequency: Every incident (2-3 per week across the organization)
- Impact: 12 minutes average added to MTTR per incident; risk of following outdated procedures

### Secondary Users
- **Engineering Managers**: Benefit from faster onboarding and reduced dependency on senior engineers for knowledge transfer
- **Platform Engineering**: Benefit from reduced support ticket volume as engineers self-serve

### Anti-Users
- **External customers**: This is an internal engineering tool only
- **Non-engineering staff**: Finance, HR, marketing documentation is out of scope

---

## Proposed Solution

### Overview
Build a GenAI-powered knowledge platform that unifies engineering documentation from all six source systems into a single conversational interface. Engineers ask questions in natural language and receive contextual answers with source attribution, rather than a list of search results. The platform uses Retrieval-Augmented Generation (RAG) over indexed knowledge bases to ground answers in verified internal documentation rather than general model knowledge.

### Before / After

| Dimension | Before | After |
|-----------|--------|-------|
| Finding a Golden Path | Search Confluence, scan IDP catalog, ask in Slack | Ask: "How do I create a new Python API service?" and receive the Golden Path with setup steps |
| Onboarding question | Ask buddy, wait for response, get pointed to a wiki page | Ask: "How do I get access to the payments dev environment?" and receive the answer with access request links |
| Incident runbook lookup | Search Confluence during incident, hope it is current | Ask: "How do I restart the auth-service in production?" and receive the runbook steps with last-verified date |
| Discovering API documentation | Search GitHub repos, check README files, ask the owning team | Ask: "What is the endpoint for creating a payment?" and receive the API spec with authentication requirements |

### Phased Delivery

**Phase 1 - MVP (8 weeks)**:
- RAG pipeline over Confluence and GitHub wiki content
- Conversational interface (web-based, Slack integration)
- Source attribution on all answers (link to original document)
- Confidence scoring (flag when the answer may be incomplete or outdated)
- Feedback mechanism (thumbs up/down on answers)
- Go/No-Go checkpoint at week 8

**Phase 2 - v1 (6 weeks after Phase 1 go)**:
- Expand indexing to ServiceNow, Slack archives, and internal blog
- Add IDP asset search and Golden Path recommendations
- Freshness scoring (flag stale documentation)
- Usage analytics dashboard for platform team

**Phase 3 - Scale (8 weeks after Phase 2)**:
- Personalized answers based on team context and role
- Automated documentation gap detection (questions with no good answer)
- Integration with incident response workflow (suggest relevant runbooks during incidents)
- API for embedding knowledge search into other platform tools

---

## Success Metrics

| Metric | Baseline | Target | Measurement | Timeline |
|--------|----------|--------|-------------|----------|
| Daily search time per engineer | 52 min/day | 30 min/day (-42%) | Follow-up time study (n=40) | 3 months post-Phase 2 |
| Searches ending in "ask a colleague" | 73% | 40% | Follow-up time study observation | 3 months post-Phase 2 |
| Repeat questions in Slack channels | 31% of messages | 15% | Slack analytics | 6 months post-Phase 1 |
| Monthly active users | 0 | 500+ (60% of engineering) | Platform analytics | 3 months post-Phase 1 |
| Answer helpfulness rating | N/A | 80%+ thumbs up | In-platform feedback | Ongoing from Phase 1 |
| New hire time to first deploy | 3.2 weeks | 2.2 weeks | Onboarding tracker | 6 months post-Phase 2 |
| Documentation NPS | -12 | +20 | Quarterly developer experience survey | 6 months post-Phase 2 |
| Annual engineering hours recovered | 0 | 40,000+ hours (~$6M) | Time study extrapolation | 12 months post-launch |

---

## Investment Required

| Category | Estimate | Notes |
|----------|----------|-------|
| People | 4 engineers x 2 quarters (Phase 1-2), 2 engineers ongoing | Dedicated team from existing platform engineering headcount |
| Timeline | MVP: 8 weeks, v1: +6 weeks, Scale: +8 weeks | ~5 months to full capability |
| Infrastructure | $8,000/month | AWS Bedrock, OpenSearch Serverless, ECS Fargate |
| Tooling/Licenses | $0 | Using existing AWS services under enterprise agreement |
| **Total (Year 1)** | **~$850K** | Primarily engineering time (fully loaded) |

**Opportunity Cost**: The 4-engineer team will not be available for other platform initiatives during Phase 1-2. Specifically, the planned CI/CD pipeline optimization project will be deferred by one quarter.

**Payback Analysis**: The platform addresses approximately $6.2M in annual lost productivity. At an $850K year-one investment, the payback period is approximately 7 weeks after the capability reaches target adoption (500+ MAU). Even at 50% of projected impact, the payback period is under 4 months.

---

## Technical Approach

### Architecture Overview
The platform consists of three layers: an ingestion pipeline that indexes content from source systems, a RAG engine that retrieves relevant documents and generates contextual answers using a foundation model, and a delivery layer providing web and Slack interfaces.

### Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Foundation model | AWS Bedrock (Claude) | Enterprise agreement in place, data residency in our AWS accounts, no data leaves the VPC |
| Vector store | OpenSearch Serverless | Managed, scales with index size, existing team expertise with OpenSearch |
| Build vs. buy | Build on Bedrock | Commercial knowledge platforms (Glean, Guru) evaluated but do not integrate with IDP asset catalog and require data export outside our environment |
| Ingestion approach | Scheduled crawl + webhook | Confluence and GitHub support webhooks for real-time updates; other sources use scheduled crawl (hourly) |

### Integration Points
- **Confluence**: API connector for page content and metadata
- **GitHub**: API connector for wiki and README content
- **Slack**: Bot integration for conversational interface; archive indexing via Slack API
- **IDP**: Direct integration with asset catalog and Golden Path registry
- **ServiceNow**: Knowledge base API connector

### Open Technical Questions
- Chunking strategy for long-form documents needs experimentation during Phase 1
- Handling of code snippets in documentation (embed vs. link) needs user testing
- Permission model: should the platform respect source system permissions or provide open access to all indexed content?

---

## Risks & Dependencies

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Answer quality insufficient for adoption | Medium | High | Invest in chunking optimization and prompt engineering during Phase 1. Confidence scoring flags low-quality answers. Feedback loop drives continuous improvement. |
| Engineers do not adopt (prefer existing habits) | Medium | High | Slack integration meets engineers where they already work. Champion program with 10 early adopters. Do not mandate; let quality drive adoption. |
| Stale documentation produces incorrect answers | High | Medium | Freshness scoring in Phase 2. Flag content older than 6 months. Automated stale content reports to documentation owners. |
| Bedrock costs exceed estimates at scale | Low | Medium | Usage-based pricing with monitoring. Set billing alarms. OpenSearch Serverless scales down during off-hours. |
| Scope creep beyond engineering knowledge | Medium | Low | Brief explicitly scopes to engineering documentation. Non-engineering requests deferred to separate evaluation. |

### Dependencies

| Dependency | Team | Status | Risk if Delayed |
|------------|------|--------|----------------|
| Confluence API access for indexing | IT Operations | Approved | Phase 1 cannot start without this |
| Slack bot approval for production workspace | Security | In review | Slack integration deferred to Phase 1 week 4 if delayed |
| Bedrock model access in production AWS account | Cloud Engineering | Approved | Phase 1 cannot start without this |

---

## Go/No-Go Criteria (After Phase 1 - Week 8)

### Go (Continue to Phase 2)
- [ ] MVP deployed and accessible to pilot group (50 engineers)
- [ ] 30+ weekly active users within 2 weeks of pilot availability
- [ ] Answer helpfulness rating > 70% (thumbs up)
- [ ] Median answer latency < 5 seconds
- [ ] No data leakage or permission violations identified

### No-Go (Stop and Reassess)
- [ ] MVP delayed > 2 weeks beyond plan
- [ ] Fewer than 15 weekly active users after 2 weeks of pilot
- [ ] Answer helpfulness rating < 50%
- [ ] Significant hallucination rate (answers not grounded in source documents > 15%)
- [ ] Data residency or security concern identified

### Pivot (Change Approach)
- [ ] Users prefer search-style results over conversational answers (pivot to enhanced search)
- [ ] Specific knowledge domains (e.g., runbooks) show high value while others show low value (narrow scope)

---

## Alternatives Considered

### Alternative 1: Do Nothing
Continue with the current fragmented documentation landscape. Engineers will continue spending 52 minutes per day searching, and knowledge fragmentation will worsen as the organization grows. Cost of inaction: approximately $6.2M annually in lost productivity, plus unmeasured costs in slower onboarding, longer MTTR, and senior engineer bottlenecks. This cost will increase as headcount grows.

### Alternative 2: Adopt Glean or Guru
Commercial enterprise knowledge platforms that provide AI-powered search across connected data sources. Evaluated in Q4 2025.
- Cost: $15-25/user/month ($144K-$240K/year at 800 engineers)
- Limitations: No integration with IDP asset catalog or Golden Path registry. Requires data export to vendor's infrastructure, which conflicts with data residency requirements for regulated content. Limited customization of answer generation.
- Verdict: Does not meet data residency requirements and cannot integrate with the IDP.

### Alternative 3: Improve Existing Documentation
Invest in documentation quality improvement: hire a technical writer, establish documentation standards, consolidate to fewer systems.
- Cost: $150K/year (1 technical writer + tooling)
- Limitations: Addresses quality but not discoverability. Does not solve the multi-system fragmentation problem. Does not scale: one technical writer cannot maintain documentation across 200+ services.
- Verdict: Complementary to the proposed solution (better documentation makes the knowledge platform more effective) but insufficient alone.

### Recommendation
The proposed GenAI knowledge platform is the recommended approach because it addresses both discoverability and fragmentation without requiring all content to be migrated to a single system. It meets data residency requirements by running entirely within our AWS environment, and it integrates directly with the IDP to leverage the existing Golden Path and asset catalog investments. The documentation quality improvement (Alternative 3) should be pursued in parallel as a complementary initiative.

---

## Approval

| Approver | Role | Decision | Date |
|----------|------|----------|------|
| [VP of Engineering] | Sponsor | Approved | March 2026 |
| [CISO] | Security review | Approved with conditions (permission model review in Phase 1) | March 2026 |
| [Director, Cloud Engineering] | Infrastructure review | Approved | March 2026 |
