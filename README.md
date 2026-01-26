# The CloudOps Status Page Challenge

## AWS (Python + Terraform + Ansible)

## Scope and SLOs (Service-Level Objectives)

Define 3–5 endpoints you will monitor (your portfolio site, an API endpoint, a public service). Choose check frequency (ex: every 5 minutes), what counts as “down” (timeout, non-2xx, latency threshold), and what the status page must show (current state, last check time, incident history). This is your acceptance criteria.

## HTML

Create a simple status page in HTML. It should include a header, a “system status” banner, and a table/list of monitored services. Start with placeholder values so you can build the UI before the backend exists.

## CSS

Style the page with CSS so it’s readable and looks intentional. Use clear status colors/labels (Up, Degraded, Down), spacing, and a layout that works on mobile. It does not need to be fancy. It needs to be professional.

## Static Website

Deploy the status page as an S3 static website. This is your front end hosting layer. The page should load quickly and reliably.

## HTTPS

Put CloudFront in front of your S3 site so the status page loads over HTTPS. HTTPS is non-negotiable for anything public-facing.

## DNS

Point a custom domain or subdomain to CloudFront (Route 53 is easiest, but any DNS provider works). Example: status.yourdomain.com. This makes it feel real and makes it resume-ready.

## JavaScript

Use a small amount of JavaScript to fetch live status data from your API and render it on the page. At minimum, the JS should call GET /status and update the DOM with per-service status and the “last updated” timestamp.

## Database

Store check results and incident records in DynamoDB. You need at least two access patterns: “latest status per service” and “recent history for a service.” Design your partition/sort keys to support those reads efficiently.

## API

Do not read DynamoDB directly from the browser. Create an API layer that the front end calls. Use API Gateway endpoints like:

## GET /status (current status summary)

## GET /history?service=name (recent checks or incidents)

## Python

Implement the API handlers in Python (Lambda). Use boto3 to query DynamoDB, normalize the response format, and return clean JSON. This is where you show backend fundamentals: validation, error handling, and structured logging.

## Monitoring Runner

Create the actual “monitoring engine.” Use an EventBridge schedule to run checks every N minutes. The runner (Lambda in Python) should:

request each endpoint with a timeout

measure latency and record status code

write results to DynamoDB

detect state changes (Up→Down, Down→Up)

## Incident Tracking

Add incident lifecycle logic. When a service first fails, open an incident record (start time, severity, details). When it recovers, close the incident (end time, duration). The status page should show open incidents and recent incident history, not just raw checks.

## Alerts

When an incident opens (or when failures cross a threshold), notify someone. Start with SNS email. Include service name, timestamp, failure reason, and a link to the status page. Optional upgrade: Slack via webhook Lambda.

## Tests

Write tests for your Python code. At minimum:

unit tests for the health-check logic (timeouts, non-200, latency thresholds)

unit tests for state-change and incident logic

unit tests for API response shapes

 Optional: a deployment smoke test that hits the live API endpoint.

## Infrastructure as Code (Terraform)

Do not build this by clicking in the console. Use Terraform to provision:

S3 bucket + CloudFront + ACM + Route 53

API Gateway + Lambda + IAM roles/policies

DynamoDB tables

EventBridge schedules + permissions

This is your Terraform “first project,” so keep it clean: inputs, outputs, and a simple module structure.

Configuration Management (Ansible)

Use Ansible for something real. Two good choices:

Provision an “ops toolbox” EC2 instance and configure it (packages, users, shell tools, diagnostic scripts), or

Standardize your dev environment (install tooling, configure git hooks, consistent commands)

Document what Ansible is responsible for vs Terraform.

## Source Control

Use GitHub repos for everything (recommended: one mono-repo with /frontend, /backend, /infra, or separate repos if you want to mirror the original challenge). Enforce branch protections and PR checks so it looks like professional engineering work.

## CI/CD (Back end + Infra)

Set up GitHub Actions so that on push/PR:

run lint + pytest

run terraform fmt + terraform validate

On merge to main:

deploy Terraform (plan/apply via protected environment)

package and deploy Lambda code

Never commit AWS credentials. Use GitHub OIDC to assume an AWS role.

## CI/CD (Front end)

Set up GitHub Actions so that changes to the front end automatically deploy to S3 and invalidate CloudFront. This gives you a clean, repeatable release process.

## Observability and Hardening

Add CloudWatch dashboards/logging, sensible alarms (runner failures, API errors), and tight IAM. Add basic rate limiting / WAF if you want extra points. Make sure secrets are not in code. Ensure CORS is correct for your domain.

## Blog Post

Write a short blog post describing what you built and what you learned. Include real lessons: Terraform mental model, IAM mistakes you fixed, how you designed DynamoDB keys, and how you implemented incident state transitions. Link it from the status page.
