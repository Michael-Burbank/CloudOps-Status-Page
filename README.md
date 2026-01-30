# CloudOps Status Page

A professional, cloud-native status page solution for monitoring and displaying the health of multiple endpoints, built with AWS (Python, Terraform, Ansible), and featuring robust CI/CD with GitLab CI. The status page and the backend run on an Amazon Linux 2023 EC2 host behind an ALB, and CloudFront in front for HTTPS, caching, and a clean public edge.

## Table of Contents

- [CloudOps Status Page](#cloudops-status-page)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Features](#features)
  - [Architecture](#architecture)
  - [Getting Started](#getting-started)
  - [Infrastructure as Code](#infrastructure-as-code)
  - [Configuration Management](#configuration-management)
  - [CI/CD](#cicd)
    - [GitLab CI](#gitlab-ci)
  - [Roadmap](#roadmap)
  - [Contributing](#contributing)
  - [License](#license)

---

## Overview

CloudOps Status Page is a full-stack solution for real-time monitoring of web services and APIs. It provides a public-facing status page, incident tracking, and alerting, all deployed using modern DevOps practices.

---

## Features

- Monitor 3–5 endpoints (websites, APIs, public services)
- Customizable check frequency (e.g., every 5 minutes)
- Detects downtime (timeouts, non-2xx, latency thresholds)
- Professional HTML/CSS status page with live updates
- Responsive design for mobile and desktop
- S3 static website hosting with CloudFront (HTTPS)
- CloudFront in front of ALB and S3 for edge HTTPS and caching
- Custom domain support via Route 53
- Live status and incident history via JavaScript/API
- DynamoDB for storing check results and incidents
- Backend API and monitoring runner on EC2 (Amazon Linux 2023)
- ALB for routing API traffic to EC2
- Incident lifecycle management and alerting (SNS/Slack)
- Automated tests for backend logic and API
- Infrastructure as Code with Terraform
- Configuration management with Ansible
- Source control and mirroring (GitLab => GitHub)
- CI/CD with GitLab CI

---

## Architecture

User ──> Route 53 ──> CloudFront ──> S3 (Static Site)
│
└──> CloudFront ──> ALB ──> EC2 (API & Monitoring Runner)
│
└──> DynamoDB (Status, History, Incidents)
│
└──> SNS/Slack (Alerts)

**CloudFront**: CDN in front of both S3 (static site) and ALB (API)

**S3**: Hosts static HTML/CSS/JS files

**ALB**: Routes `/api/*` traffic to EC2

**EC2**: Runs Python API (FastAPI/Flask) and monitoring runner (systemd timer)

**DynamoDB**: Stores status, check history, and incident records

**SNS**: Sends email alerts (Slack optional)

**Route 53**: Custom domain for status page

**ACM**: TLS certificates for HTTPS

---

## Getting Started

1. **Clone the repository**
2. **Configure endpoints and SLOs** in the configuration files
3. Use Terraform to provision the AWS infrastructure (S3, CloudFront, ALB, EC2, Route 53, DynamoDB, SNS)
4. **Configure Ansible** for EC2 instance setup and ops toolbox
5. **Set up CI/CD** for automated testing and deployment

---

## Infrastructure as Code

All AWS resources are provisioned using Terraform:

- S3 bucket for static site assets
- CloudFront distribution with two origins (S3 and ALB)
- ACM certificate and Route 53 records
- VPC, security groups
- ALB + target group + listener
- EC2 instance (Amazon Linux 2023, t2.small, gp3 30GB EBS)
- IAM instance profile (least privilege for DynamoDB and SNS)
- DynamoDB tables
- SNS topic/subscription
- Optional CloudWatch logs and alarms

> **Tip:** Use modules, inputs, and outputs for clean, reusable code.

---

## Configuration Management

Ansible is used for:

- Provisioning and configuring the EC2 instance (users, packages, Python environment)
- Setting up systemd services for API and monitoring runner
- Nginx config (if used)
- Basic hardening and logging
- Standardizing dev environments (tooling, git hooks, commands)

> **Note:** Document what Ansible manages vs. Terraform.

---

## CI/CD

### GitLab CI

- Lint, test, and validate on push/PR
- Deploy infrastructure and backend on merge to main
- Pipeline step to push changes to GitHub (mirror)
- Lint + pytest for Python code
- `terraform fmt` + `terraform validate` for IaC
- Deploy backend code to EC2 and restart systemd services
- Frontend deploys to S3 and invalidates CloudFront

> **Security:** Never commit AWS credentials. Use OIDC for GitHub Actions to assume AWS roles.

---

## Roadmap

1. Baseline health checks and UI wiring  
   Lock endpoint list, timeouts, latency thresholds, and consecutive-check rules. Wire the status page JavaScript to the API (served from EC2) so the UI updates from live data.

2. EC2 host setup with Ansible  
   Configure the Amazon Linux 2023 EC2 instance with Ansible: users, packages, Nginx (if used), and systemd units for the API and monitoring runner.

3. Monitoring runner and DynamoDB persistence  
   Build the runner as a Python script scheduled with a systemd timer on EC2. Write results to DynamoDB and maintain a clean history view for each service.

4. Incident tracking and notifications  
   Add incident open/close logic based on consecutive failures/recoveries. Send SNS email alerts (and optionally Slack) when incidents open.

5. CloudFront, DNS, and production hardening  
   Place CloudFront in front of both S3 (static site) and ALB (API). Point DNS through Route 53. Harden security: least-privilege IAM, minimal inbound ports, log visibility, and basic alarms.

---

## Contributing

Contributions are welcome! Please open issues or pull requests. Follow these guidelines:

1. Fork the repo and create a feature branch
2. Write clear, concise commit messages
3. Add/Update tests as needed
4. Ensure all CI checks pass
5. Submit a pull request for review

---

## License

This project is licensed under the MIT License.
