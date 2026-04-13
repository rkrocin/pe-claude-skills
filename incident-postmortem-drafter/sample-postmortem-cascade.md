# Incident Postmortem: Customer Authentication Cascade Failure During Peak Traffic

**Date**: April 2, 2026
**Author**: SRE Team
**Status**: Final
**Severity**: SEV1 - Critical

---

## Summary

A sustained traffic spike during a promotional event exceeded the authentication service's connection pool capacity, triggering a cascade failure that rendered login and session validation unavailable for all customer-facing applications for 23 minutes. Approximately 180,000 customers were unable to log in or complete authenticated actions during the outage window. The incident was compounded by a retry storm from downstream services that amplified load on the already-saturated authentication service. Resolution required both scaling the authentication service and deploying circuit breakers on the three highest-volume downstream consumers.

**Duration**: 23 minutes (14:12 to 14:35 CT)
**Time to Detect (TTD)**: 2 minutes
**Time to Mitigate (TTM)**: 18 minutes (from first alert to impact mitigated)
**Time to Resolve (TTR)**: 21 minutes (from first alert to stable state confirmed)

---

## Severity & Impact

**Severity**: SEV1 - Critical
Complete loss of authentication capability affecting all customer-facing applications during peak business hours.

**User Impact**:
- 100% of login attempts failed for 23 minutes
- 100% of authenticated API calls failed (session validation unavailable)
- Approximately 180,000 unique customers impacted based on typical traffic during this window
- Mobile app users experienced force-logout and were unable to re-authenticate
- Web users saw a generic error page with no status communication

**Business Impact**:
- Estimated $310,000 in lost transaction revenue during the window
- Promotional event conversion rate dropped to 0% during outage, partial recovery after
- SLA breach: 23 minutes against a 15-minute monthly allowance for authentication services
- 340+ customer support contacts within the first hour
- Social media mentions of outage (contained, no major press coverage)

**Systems Affected**:
- auth-service (primary failure point)
- auth-db connection pool (exhausted)
- web-app, mobile-api, partner-api (cascading impact)
- transaction-service, account-service, rewards-service (session validation failures)

---

## Timeline

All times in Central Time (CT).

| Time | Event | Source |
|------|-------|--------|
| 13:45 | Marketing promotional push notification sent to 2M customers | Marketing platform log |
| 13:50 | Login traffic begins increasing, reaching 3x normal peak within 5 minutes | CloudWatch |
| 14:05 | Auth-service request latency increases from 50ms p99 to 200ms p99 | CloudWatch |
| 14:08 | Auth-db connection pool reaches capacity (200/200 connections) | RDS Performance Insights |
| 14:10 | Auth-service begins returning 503 errors as connection pool requests queue and timeout | Application logs |
| 14:12 | Downstream services begin aggressive retries against auth-service (retry storm) | CloudWatch request counts |
| 14:12 | Auth-service error rate exceeds 90%; effective total authentication outage | CloudWatch |
| 14:14 | PagerDuty SEV1 alert fires for auth-service availability | PagerDuty |
| 14:15 | On-call SRE acknowledges page, opens incident channel | PagerDuty, Slack |
| 14:17 | Incident commander role assumed by SRE team lead | Slack incident channel |
| 14:18 | Initial diagnosis: auth-db connection pool exhausted, auth-service instances healthy but blocked | CloudWatch, RDS console |
| 14:20 | VP of Engineering notified per SEV1 protocol | Slack |
| 14:22 | First mitigation attempt: increase auth-service desired count from 10 to 30 | ECS console |
| 14:25 | New auth-service instances launch but immediately exhaust against same connection pool limit | ECS events, RDS console |
| 14:26 | Team realizes scaling auth-service without scaling connection pool makes the problem worse | Slack incident channel |
| 14:28 | Second mitigation: increase RDS max connections via parameter group (200 to 500) | RDS console |
| 14:29 | RDS parameter change requires instance restart; team decides to proceed | Slack incident channel |
| 14:30 | Parallel mitigation: deploy circuit breakers on web-app, mobile-api, partner-api to stop retry storm | Emergency deploy |
| 14:32 | Circuit breakers deployed; retry storm subsides; inbound request rate drops 60% | CloudWatch |
| 14:33 | RDS instance restart complete; connection pool expanded to 500 | RDS console |
| 14:34 | Auth-service instances begin acquiring connections; error rate begins declining | CloudWatch |
| 14:35 | Error rate drops below 1%; authentication service functional | CloudWatch |
| 14:38 | All customer-facing applications confirmed operational | Synthetic monitors |
| 14:40 | All-clear declared | Slack incident channel |
| 14:45 | Customer support provided template response for affected customers | Zendesk |
| 15:30 | Auth-service scaled back to 15 instances (right-sized for elevated post-promotion traffic) | ECS console |

---

## Contributing Factors

### Immediate Trigger
A marketing promotional push notification drove a sudden 3x traffic spike that exceeded the authentication service's database connection pool capacity. The promotion was not coordinated with engineering, so no pre-scaling was performed.

### Enabling Conditions

1. **Fixed connection pool with no auto-scaling or queuing**: The auth-service database connection pool was statically configured at 200 connections with no overflow queuing or dynamic scaling. When demand exceeded 200 concurrent connections, all additional requests failed immediately rather than queuing or degrading gracefully.

2. **No coordination between marketing and engineering for promotional events**: The marketing team's promotional calendar was not shared with engineering. There was no process for pre-scaling infrastructure ahead of known traffic events. The push notification reached 2M customers simultaneously with no traffic shaping.

3. **Downstream services lacked circuit breakers**: The three highest-volume consumers of the auth-service (web-app, mobile-api, partner-api) had no circuit breaker pattern implemented. When auth-service began returning errors, these services retried aggressively, amplifying the load 4-5x beyond organic traffic.

4. **Auth-service had no load shedding or rate limiting**: The service accepted all inbound requests regardless of backend capacity. Without admission control, the service could not protect itself when demand exceeded database capacity.

### Amplifying Factors

1. **Retry storm from downstream services**: Aggressive retries from three downstream services amplified the traffic from 3x organic to approximately 12x organic within 2 minutes of the first errors. This turned a capacity issue into a complete outage.

2. **Initial mitigation attempt worsened the situation**: Scaling auth-service instances without increasing the connection pool created more processes competing for the same 200 connections, adding connection acquisition latency without increasing throughput.

3. **RDS parameter change required instance restart**: Increasing the max connections on the RDS instance required a restart, adding approximately 4 minutes to the resolution timeline during a SEV1 incident. A pre-configured higher limit or Aurora Serverless would have avoided this delay.

---

## Resolution

**Immediate mitigation**: Deployed circuit breakers on the three primary downstream consumers to stop the retry storm, then increased the RDS connection pool limit via parameter group change (requiring instance restart). Scaled auth-service to 15 instances to handle elevated post-promotion traffic.

**Verification**: CloudWatch error rate confirmed below 1% within 3 minutes of the combined mitigation. Synthetic login monitors confirmed end-to-end authentication flow operational. Customer support confirmed reports subsided.

**Permanent fixes**: Captured in action items below. The immediate mitigations (circuit breakers, connection pool increase) remain in place but the systemic issues (no load shedding, no marketing coordination, no auto-scaling) require additional work.

---

## Lessons Learned

### What Went Well
- **SEV1 alert fired within 2 minutes of outage onset.** Detection was fast and automated.
- **Incident commander was established within 3 minutes.** SRE team lead took command and maintained structured communication throughout.
- **Parallel mitigation tracks were effective.** The team split into two tracks (circuit breakers and database scaling) simultaneously, which was faster than sequential attempts.
- **VP notification happened per protocol.** Executive communication followed the SEV1 playbook without delays.

### What Went Poorly
- **First mitigation attempt made things worse.** Scaling the auth-service without addressing the connection pool bottleneck was a predictable mistake that cost 3-4 minutes. The team did not have a runbook for connection pool exhaustion scenarios.
- **No advance warning of the traffic event.** The marketing promotion was not visible to engineering. Pre-scaling the auth-service and database would have prevented the incident entirely.
- **No circuit breakers existed before the incident.** The retry storm pattern is well-documented in distributed systems literature. Circuit breakers should have been implemented proactively, not as an emergency deploy during a SEV1.
- **Customer communication was reactive.** No status page update or proactive customer notification was issued during the 23-minute outage. Customers discovered the issue by experiencing it.

### Where We Got Lucky
- **The promotion was sent at 13:45, not 12:00.** If the notification had been sent during the absolute peak hour, the traffic multiplier would have been higher and the blast radius larger.
- **The SRE team lead happened to be at their desk.** The incident commander was not the on-call; they were available by coincidence. On a different day, incident commander assignment could have taken longer.
- **No data corruption occurred.** Database connections that timed out did so cleanly. If in-flight transactions had been corrupted by the connection pool exhaustion, recovery would have been significantly more complex.

---

## Action Items

| Priority | Action | Contributing Factor | Owner | Deadline | Status |
|----------|--------|-------------------|-------|----------|--------|
| P1 | Implement circuit breakers with exponential backoff on all auth-service consumers (web-app, mobile-api, partner-api, transaction-service, account-service) | No circuit breakers | Platform Engineering | April 16, 2026 | In Progress |
| P1 | Implement rate limiting / admission control on auth-service to shed load when database capacity is exhausted | No load shedding | Platform Engineering | April 16, 2026 | Open |
| P1 | Establish marketing-engineering coordination process: promotional calendar shared 2 weeks ahead, pre-scaling checklist for events exceeding 2x normal traffic | No marketing coordination | Engineering Leadership + Marketing | April 9, 2026 | Open |
| P2 | Migrate auth-db to Aurora Serverless or implement connection pooling proxy (PgBouncer/RDS Proxy) to handle connection scaling without instance restarts | Fixed connection pool, restart required | Platform Engineering | April 30, 2026 | Open |
| P2 | Create runbook for auth-service capacity incidents, including connection pool exhaustion diagnosis and correct mitigation sequence | First mitigation worsened situation | SRE | April 11, 2026 | Open |
| P2 | Implement automated pre-scaling triggers based on known event calendar (scale auth-service and database ahead of scheduled promotions) | No advance scaling | Platform Engineering | May 7, 2026 | Open |
| P3 | Add status page integration for automated incident communication when SEV1/SEV2 alerts fire | No proactive customer communication | SRE | May 14, 2026 | Open |

---

## Leadership Summary

A marketing promotional push notification at 13:45 CT drove a 3x traffic spike that exceeded the authentication service's database connection pool capacity. Downstream services without circuit breakers amplified the load through aggressive retries, causing a complete authentication outage lasting 23 minutes. Approximately 180,000 customers were affected with an estimated $310,000 in lost transaction revenue. This breached the authentication service SLA (23 minutes against a 15-minute monthly allowance).

Three systemic factors enabled this incident: the authentication database connection pool had no dynamic scaling, downstream services had no circuit breakers to limit retry storms, and engineering had no visibility into the marketing promotional calendar. The immediate trigger (traffic spike) was entirely predictable and preventable with advance coordination.

Seven action items have been identified. The three P1 items (circuit breakers, rate limiting, marketing coordination) are targeted for completion within two weeks and will directly prevent recurrence. The remaining items address structural improvements to connection scaling, runbook coverage, pre-scaling automation, and customer communication.

---

## Appendix

### Supporting Data
- CloudWatch auth-service dashboard: [link]
- RDS Performance Insights during incident: [link]
- PagerDuty incident: [link]
- Slack incident channel: #inc-2026-04-02-auth-outage

### Related Incidents
- INC-2026-01-22: Auth-service latency spike during minor traffic increase (SEV3, resolved with manual scaling). This was an early warning signal that the auth-service had limited capacity headroom. The action item from that incident (evaluate auto-scaling) was deprioritized and had not been completed.
