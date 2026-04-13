# Static Frontend Golden Path

Reference definition for static frontend service scaffolds. Covers single-page applications, documentation sites, marketing pages, and internal dashboards served as static assets.

## Directory Structure

```
{service-name}/
├── app/
│   ├── src/
│   │   ├── index.html           # Entry point (or framework equivalent)
│   │   ├── pages/               # Page components or routes
│   │   ├── components/          # Shared UI components
│   │   ├── assets/              # Static assets (images, fonts, icons)
│   │   ├── styles/              # CSS/SCSS/Tailwind configuration
│   │   └── config.{ext}         # Runtime configuration (environment, API endpoints)
│   ├── tests/
│   │   └── test_components.{ext}
│   ├── package.json
│   └── vite.config.{ext}        # Or next.config.js, etc.
├── infra/
│   ├── main.tf                  # S3 + CloudFront + Route53
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── .github/workflows/ci-cd.yml
├── docs/
│   ├── adr-001-service-architecture.md
│   └── runbook.md
├── README.md
├── .gitignore
└── Makefile
```

## Framework Patterns

### React (Vite) - Default
- Build tool: Vite
- Styling: Tailwind CSS
- Routing: React Router
- Testing: Vitest with React Testing Library
- Build output: `dist/` directory with hashed assets

### Next.js (Static Export)
- Static export mode (`output: 'export'`)
- File-based routing
- Image optimization for static export
- Testing: Jest with React Testing Library

### Plain HTML/CSS/JS
- No build step required
- Suitable for simple internal tools or documentation
- Assets served directly from S3

## Infrastructure Patterns (Terraform)

### S3 + CloudFront (Default)
```
Resources:
- aws_s3_bucket (private, no public access)
- aws_s3_bucket_public_access_block (all blocked)
- aws_s3_bucket_server_side_encryption_configuration
- aws_cloudfront_distribution
  - Origin: S3 with Origin Access Control (OAC)
  - Default root object: index.html
  - Custom error response: 403/404 -> /index.html (for SPA routing)
  - Cache policy: CachingOptimized for static assets
  - Response headers policy: SecurityHeadersPolicy
  - TLS: TLSv1.2_2021 minimum
  - Price class: PriceClass_100 (US/EU) or PriceClass_All
- aws_cloudfront_origin_access_control
- aws_route53_record (A/AAAA alias to CloudFront)
- aws_acm_certificate (us-east-1, required for CloudFront)

Key decisions:
- OAC over OAI (newer, more secure S3 access pattern)
- Private S3 bucket: all access through CloudFront only
- SPA routing: custom error responses redirect to index.html
- Cache invalidation on deploy (/* pattern)
- Security headers via CloudFront response headers policy
```

### Security Headers
CloudFront response headers policy should include:
- `Strict-Transport-Security: max-age=31536000; includeSubDomains`
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `Content-Security-Policy`: Configured per application (default-src, script-src, style-src)
- `Referrer-Policy: strict-origin-when-cross-origin`

## CI/CD Pipeline

```yaml
Stages:
  1. Install & Lint
     - Install dependencies (npm ci)
     - Run ESLint / Prettier check
     - Run TypeScript type check (if applicable)

  2. Test
     - Run unit tests
     - Generate coverage report

  3. Build
     - Build production bundle
     - Verify bundle size (fail if exceeds threshold)
     - Generate source maps (upload to error tracking, not deployed)

  4. Deploy
     - Sync build output to S3 bucket (aws s3 sync)
     - Invalidate CloudFront cache
     - Smoke test: HTTP GET on the deployed URL returns 200

Environment strategy:
  - Dev: auto-deploy on push to main
  - Staging: auto-deploy after dev
  - Production: manual approval, then sync + invalidate
```

## Observability

### Client-Side
- Error tracking (Sentry or CloudWatch RUM)
- Performance monitoring (Core Web Vitals)
- Analytics (if applicable, privacy-respecting implementation)

### Infrastructure
- CloudFront access logs to S3
- CloudFront metrics: requests, error rate, cache hit ratio
- S3 access logs
- CloudWatch alarms on 5xx error rate and origin latency

### Alerting
- CloudFront 5xx error rate > 1%: alert (P2)
- Cache hit ratio drops below 80%: alert (P3)
- Certificate expiration within 30 days: alert (P2)
