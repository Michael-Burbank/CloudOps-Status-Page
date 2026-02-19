# CloudOps Status Page

I’m building this project to monitor public-facing website/API health from AWS and publish a simple status page.  
My current focus is operational clarity over complexity: small, observable, and easy to explain.

Right now I’m starting with one endpoint and a clean pipeline, then expanding in phases.

---

## What I’m Building (Current Direction)

I want a lightweight monitoring system that does three things well:

1. Makes a normal HTTPS request to a public endpoint
2. Decides if the service is healthy (up/down + latency)
3. Sends logs, metrics, and alarms to CloudWatch

This gives me an external observer view, which is exactly what I need for a practical CloudOps project.

---

## Phase 1 Architecture (Current)

### Backend flow

- An **EC2 instance** in my VPC runs a Python monitoring script on a schedule
- The script sends HTTPS requests to my target endpoint(s)
- The script records:
  - HTTP status code
  - latency
  - errors/timeouts
  - timestamp
- Results are written to:
  - **CloudWatch Logs** (detailed run records)
  - **CloudWatch Metrics** (health + latency time series)
- **CloudWatch Alarms** trigger on repeated failures or high latency

### Frontend (early/placeholder)

- Static status UI hosted on **S3**
- Initially can use placeholder/static data
- Later will consume my REST API output

---

## Terraform Scope

I’m using Terraform as the source of truth for infrastructure.

### Networking

- VPC
- Public and/or private subnets
- Internet Gateway and/or NAT Gateway (depending on final design)
- Route tables and associations

### Security

- Security groups for EC2/API access
- Network ACLs (if needed)

### Compute

- EC2 instance configuration
- IAM instance profile + role for CloudWatch access
- Role designed to expand later for DynamoDB/SNS writes

### Storage and Frontend

- S3 bucket for static status page
- Optional S3 website settings and bucket policy
- Optional CloudFront distribution in later phase

### Monitoring

- CloudWatch metric alarms for health and latency
- Optional CloudWatch dashboard (later)

### CloudFormation Example (Learning/Interview)

- One small CloudFormation stack managed alongside Terraform  
  (for a low-risk resource like SNS topic or log group)

---

## AWS Services in This Project

### In use now

- Amazon EC2
- Amazon VPC
- AWS IAM
- Amazon CloudWatch (Logs, Metrics, Alarms)
- Terraform

### Planned next

- Amazon DynamoDB (history/incidents)
- Amazon SNS (notifications)
- Amazon S3 + CloudFront (public status page)
- AWS CloudFormation (comparison example stack)

---

## Phased Roadmap

### Phase 1 — Single endpoint monitoring (current)

- Build EC2-based monitor script
- Schedule with systemd or cron
- Send logs/metrics to CloudWatch
- Configure baseline alarms
- Manage resources with Terraform

### Phase 2 — Persistence and history

- Add DynamoDB table
- Store each check result (endpoint, timestamp, status, latency, error)
- Update monitor script to write records

### Phase 3 — Public status page

- Build static frontend (HTML/CSS/JS)
- Host on S3
- Read current status/history from my API
- Add CloudFront for HTTPS + edge caching

### Phase 4 — Multi-endpoint support

- Move endpoint definitions to config or DynamoDB
- Loop through multiple services in one run
- Update frontend/data model for multi-service UI

### Phase 5 — Automation and hardening

- Add GitLab CI pipeline:
  - Python linting/tests
  - `terraform fmt` and `terraform validate`
  - optional non-destructive `terraform plan`
- Tighten IAM policies
- Improve dashboards/logging
- Keep CloudFormation comparison example in repo

---

## CloudWatch Strategy

I’m using CloudWatch as my central observability layer:

- **Logs:** detailed record of each check
- **Metrics:** custom time series for health + latency
- **Alarms:** alert conditions for outages and slowness
- **Dashboards (later):** one-screen operational view

---

## Why I’m Building It This Way

I chose this design because it matches real Cloud Systems Admin work:

- EC2 host operations
- IAM role design
- network/security fundamentals
- CloudWatch-based observability
- infrastructure as code with Terraform

It also gives me clear interview talking points with a system I can actually demonstrate end to end.

---

## Local/Deployment Workflow (WIP)

1. Clone repo
2. Configure AWS credentials for your account
3. Review Terraform variables
4. Run:
   - `terraform init`
   - `terraform plan`
   - `terraform apply`
5. Verify CloudWatch Logs/Metrics/Alarms are receiving monitor data

I’ll keep this section updated as the API and frontend become fully wired.

---

## License

This project is licensed under the MIT License.
