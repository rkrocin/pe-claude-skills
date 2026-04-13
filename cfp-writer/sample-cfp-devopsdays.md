# CFP Submission: DevOpsDays Chicago 2026

## Title Options

1. **"40,000 Hours Back: How GenAI Became Our Platform's Quiet Productivity Engine"**
2. **"RAG Over Runbooks: Deploying GenAI Where Engineers Actually Need It"**
3. **"The Unsexy AI Use Case That Saved Us $6M in Engineering Productivity"**

**Recommended**: Option 3 (grounded, counterintuitive, avoids AI hype)

---

## Abstract (247 words)

Every AI announcement promises to replace engineers. Our most impactful AI deployment does something far less dramatic: it helps engineers find the documentation they already have. The result was 40,000 hours of recovered engineering productivity per year, approximately $6M in value, with no model training, no data science team, and no moonshot ambitions.

This talk is the story of deploying GenAI capabilities into an existing Internal Developer Platform at a regulated financial services company serving 15,000+ engineers. We will cover why we chose Retrieval-Augmented Generation (RAG) over fine-tuning, how we built a knowledge platform that indexes six internal documentation systems and returns contextual answers with source attribution, and what happened when engineers started using it instead of asking in Slack.

The honest part: it did not work at first. Our initial RAG implementation had a 35% hallucination rate that eroded trust within the first week of the pilot. We will share how we fixed the chunking strategy, implemented confidence scoring, and built the feedback loops that brought answer quality to 85%+ helpfulness before scaling beyond the pilot group.

Attendees will learn a practical framework for identifying high-value GenAI use cases in their own platform (hint: follow the toil, not the hype), the RAG architecture patterns that work in regulated environments, and the trust-building process that determines whether engineers actually use AI-powered tools or quietly revert to Slack.

---

## Learning Outcomes

1. Attendees will be able to identify high-value GenAI use cases in their own engineering organizations by following toil patterns rather than AI hype cycles
2. Attendees will understand RAG architecture patterns suitable for regulated environments, including data residency, source attribution, and confidence scoring
3. Attendees will learn practical techniques for improving RAG answer quality, including chunking strategies and feedback loop design
4. Attendees will understand the trust-building process required for GenAI tool adoption among engineers

---

## Detailed Outline (30 minutes)

```
0:00 - 2:00   Opening: "Our most impactful AI project is the least interesting one"
               - Set expectations: this is not an AGI talk, it is a toil reduction story
               - The gap: engineers spending 52 min/day searching for documentation

2:00 - 5:00   Why RAG Over Runbooks
               - The documentation fragmentation problem (6 systems, 73% of searches fail)
               - Why RAG fit: ground answers in verified internal content, not general knowledge
               - Why NOT fine-tuning: too expensive, too slow to update, compliance complexity

5:00 - 10:00  The Architecture
               - Ingestion pipeline (Confluence, GitHub, Slack, ServiceNow indexing)
               - Vector store (OpenSearch Serverless) and embedding strategy
               - Foundation model via AWS Bedrock (data stays in our VPC)
               - Source attribution: every answer links to the document it came from
               - Why this architecture works in a regulated environment

10:00 - 15:00 The Failure (35% Hallucination Rate)
               - Week 1 of the pilot: engineers excited, then quickly disillusioned
               - What went wrong: naive chunking produced incoherent context
               - The trust damage: once an AI tool gives a wrong answer in production, recovery is hard
               - How we paused the rollout, fixed the approach, and relaunched

15:00 - 20:00 What Fixed It
               - Chunking strategy: document-aware chunking vs. fixed-size windows
               - Confidence scoring: when the model says "I'm not sure," that is a feature
               - Feedback loops: thumbs up/down driving continuous retrieval improvement
               - The 85%+ helpfulness threshold before scaling beyond pilot

20:00 - 25:00 The Results
               - 40,000 hours of annual toil eliminated (~$6M in productivity)
               - 31% reduction in repeat Slack questions
               - New hire onboarding improvement (3.2 weeks to 2.2 weeks to first deploy)
               - Developer experience NPS from -12 to +20

25:00 - 28:00 The Framework: Finding Your Own GenAI Use Case
               - Follow the toil: where do your engineers spend time on discoverable information?
               - RAG vs. fine-tuning vs. prompt engineering: a decision tree
               - The trust curve: why pilot size and quality thresholds matter more than speed
               - What we are building next (and what we are deliberately NOT building)

28:00 - 30:00 Q&A
```

---

## Speaker Bio (118 words)

Roland Krocin is a Director of Platform Engineering at Capital One, leading developer platform integration across a 30,000+ engineer ecosystem. At Discover Financial Services, he built an Internal Developer Platform serving 15,000+ engineers and deployed GenAI/RAG capabilities that eliminated 40,000+ hours of annual engineering toil, recovering approximately $6M in productivity. His work spans cloud infrastructure, developer experience, and AI enablement in regulated financial services environments over two decades. Roland organizes the Chicago Infrastructure-as-Code User Group and is an active contributor to the Chicago platform engineering community. He holds 20+ professional certifications spanning cybersecurity (CISSP), cloud architecture (AWS SA Professional), and AI/ML (AWS GenAI Developer Professional).

---

## Notes to Reviewers

This talk addresses a gap I see in the current GenAI conversation: most talks focus on code generation or agent frameworks. The highest-value GenAI deployment at our organization was document retrieval over internal knowledge bases, which is far less glamorous but far more impactful. I want to bring that practical, unglamorous perspective to DevOpsDays.

The failure story (35% hallucination rate in week 1) is real and I believe it is the most valuable part of the talk. Many organizations are deploying RAG today and will hit the same chunking and trust problems we did.

As the organizer of the Chicago IaC User Group, I am active in the Chicago DevOps community and would welcome the opportunity to contribute to DevOpsDays Chicago. I am open to adjusting the talk length or depth based on the program committee's needs.
