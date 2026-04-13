# CFP Submission: PlatformCon 2026

## Title Options

1. **"Build It and They Won't Come: What We Learned Scaling an IDP to 15,000 Engineers"**
2. **"From 0 to 1 Million Page Views: The Adoption Playbook Behind Our Internal Developer Platform"**
3. **"The IDP Adoption Trap: Why Your Platform Needs a Developer Advocacy Practice"**

**Recommended**: Option 1 (counterintuitive hook + specific scale)

---

## Abstract (287 words)

When we launched our Internal Developer Platform, we had 20,000 reusable assets, 10 Golden Paths, and a beautiful developer portal. Adoption in the first month was 3%. Engineers continued using their own scripts, Slack threads, and tribal knowledge instead of the platform we spent a year building. We had built the product but forgotten to build the audience.

This talk is the story of how we turned that around. Over 18 months, we grew the IDP from near-zero adoption to 3,000 monthly active users, 15,000+ engineers served, and 1 million page views in the first six months after relaunching our approach. The technical platform did not change much. What changed was how we thought about developer adoption as a product and community problem, not a technology deployment.

We will cover the three shifts that made the difference: establishing a developer advocacy practice that embedded platform engineers in application teams to understand real workflows, building Golden Paths by observing how engineers actually worked rather than how we assumed they worked, and creating community feedback loops (internal meetups, office hours, contribution programs) that turned passive users into active advocates. We will share specific adoption metrics at each stage, the experiments that failed (including the "mandatory adoption" phase we reversed after two weeks), and the organizational changes required to sustain a developer advocacy function inside a platform engineering team.

Attendees will leave with a concrete adoption playbook they can apply to their own IDP initiatives, including metrics to track, organizational patterns to establish, and common traps to avoid. This talk is for platform teams who have built (or are building) an IDP and want to ensure engineers actually use it.

---

## Learning Outcomes

1. Attendees will be able to design a developer advocacy practice within a platform engineering team that drives IDP adoption through embedded engagement rather than top-down mandates
2. Attendees will learn how to measure IDP adoption using a metrics hierarchy (awareness, activation, engagement, retention) that reveals where their adoption funnel is breaking
3. Attendees will understand why mandatory platform adoption backfires and how to create voluntary adoption pull through Golden Path design and community building
4. Attendees will leave with a reusable adoption playbook including specific tactics, timelines, and metrics targets

---

## Detailed Outline (30 minutes)

```
0:00 - 2:00   Opening: "3% adoption after a year of building"
               - The moment we realized we had a product problem, not a technology problem
               - Quick context: 15,000 engineers, 20,000 assets, regulated FSI environment

2:00 - 6:00   The Before State
               - What the IDP looked like at launch (portal, Golden Paths, asset catalog)
               - Why we expected adoption to be automatic
               - The adoption metrics that told us we were wrong (3% MAU, high bounce rate)

6:00 - 10:00  Shift 1: Developer Advocacy as a Platform Function
               - What developer advocacy means inside a platform team (not external DevRel)
               - Embedding platform engineers in application teams for 2-week rotations
               - What we learned about real workflows vs. assumed workflows
               - Example: discovering that engineers searched Slack before docs 73% of the time

10:00 - 15:00 Shift 2: Golden Paths Built from Observation
               - How we redesigned Golden Paths based on embedded observation
               - Before/after: the "ideal" Golden Path vs. the one engineers actually used
               - The "paved road" principle: make the right thing the easy thing
               - Metrics: adoption curve after Golden Path redesign

15:00 - 20:00 Shift 3: Community as Adoption Engine
               - Internal meetups, office hours, contribution programs
               - The "IDP Champions" program: turning power users into advocates
               - How community feedback loops improved the platform faster than any roadmap
               - Metrics: 1M page views, developer experience NPS trajectory

20:00 - 23:00 The Mandatory Adoption Experiment (and Why We Reversed It)
               - What happened when leadership tried to mandate IDP usage
               - Two weeks of compliance theater and resentful adoption
               - Why we reversed it and what we did instead
               - Lesson: mandates generate compliance, not adoption

23:00 - 27:00 Results and Adoption Playbook
               - Before/after metrics: 3% → 60% active adoption in 18 months
               - The four-stage adoption funnel (awareness, activation, engagement, retention)
               - Where to start if your IDP has an adoption problem today
               - Three things to do in the first 30 days

27:00 - 28:00 Closing
               - The one thing to remember: your platform is a product, your engineers are customers

28:00 - 30:00 Q&A
```

---

## Speaker Bio (142 words)

Roland Krocin is a Director of Platform Engineering at Capital One, where he leads post-acquisition developer platform integration across one of the largest engineering organizations in US financial services. Previously at Discover Financial Services, he built and scaled an Internal Developer Platform serving 15,000+ engineers with 20,000+ reusable assets and 10+ Golden Paths, driving a 30% improvement in deployment frequency and eliminating 40,000+ hours of annual engineering toil through GenAI-powered developer experience capabilities. His platform engineering career spans infrastructure, cloud, and developer experience across two decades in regulated financial services. Roland organizes the Chicago Infrastructure-as-Code User Group and has authored publications on software reuse and open source adoption in enterprise environments. He holds the CISSP, AWS Solutions Architect Professional, and AWS Generative AI Developer Professional certifications among 20+ professional credentials.

---

## Notes to Reviewers

This talk draws from direct experience building and scaling an IDP at Discover Financial Services (now part of Capital One). The adoption journey described is real, including the failed mandatory adoption experiment. All metrics cited (3% initial adoption, 1M page views, 3K MAU, 30% DORA improvement) are from actual production data.

I am happy to adjust the talk duration, audience level, or focus area based on the program committee's needs. This talk has not been delivered at a prior conference, though elements have been presented at internal tech talks and the Chicago IaC User Group.

I believe this talk fills a gap in the PlatformCon program: most IDP talks focus on what to build. This talk focuses on what happens after you build it, which is where most platform teams actually struggle.
