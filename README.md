---
 CloudOps Status Page

A professional, cloud-native status page solution for monitoring and displaying the health of multiple endpoints, built with AWS (Python, Terraform, Ansible), and featuring robust CI/CD with GitLab CI and GitHub Actions.

---

# Table of Contents

- [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Features](#features)
  - [Architecture](#architecture)
  - [Getting Started](#getting-started)
  - [Infrastructure as Code](#infrastructure-as-code)
  - [Configuration Management](#configuration-management)
  - [CI/CD](#cicd)
    - [GitLab CI](#gitlab-ci)
    - [GitHub Actions](#github-actions)
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
- Custom domain support via Route 53
- Live status and incident history via JavaScript/API
- DynamoDB for storing check results and incidents
- API Gateway + Lambda (Python) backend
- EventBridge-scheduled monitoring runner (Python Lambda)
- Incident lifecycle management and alerting (SNS/Slack)
- Automated tests for backend logic and API
- Infrastructure as Code with Terraform
- Configuration management with Ansible
- Source control and mirroring (GitLab + GitHub)
- CI/CD with GitLab CI and GitHub Actions

---

## Architecture

User ──> CloudFront ──> S3 (Static Site)
     │
     └──> API Gateway ──> Lambda (Python) ──> DynamoDB
           │
           └──> SNS/Slack (Alerts)
EventBridge ──> Lambda (Monitoring Runner)

User ──> CloudFront ──> S3 (Static Site)
     │
     └──> API Gateway ──> Lambda (Python) ──> DynamoDB
           │
           └──> SNS/Slack (Alerts)
EventBridge ──> Lambda (Monitoring Runner)

---

## Getting Started

1. **Clone the repository**
2. **Configure endpoints and SLOs** in the configuration files
3. **Deploy infrastructure** using Terraform
4. **Configure Ansible** for dev environment or ops toolbox
5. **Set up CI/CD** for automated testing and deployment

---

## Infrastructure as Code

All AWS resources are provisioned using Terraform:

- S3 bucket, CloudFront, ACM, Route 53
- API Gateway, Lambda, IAM roles/policies
- DynamoDB tables
- EventBridge schedules

> **Tip:** Use modules, inputs, and outputs for clean, reusable code.

---

## Configuration Management

Ansible is used for:

- Provisioning an "ops toolbox" EC2 instance (packages, users, scripts)
- Standardizing dev environments (tooling, git hooks, commands)

> **Note:** Document what Ansible manages vs. Terraform.

---

## CI/CD

### GitLab CI

- Lint, test, and validate on push/PR
- Deploy infrastructure and backend on merge to main
- Pipeline step to push changes to GitHub (mirror)

### GitHub Actions

- Lint + pytest for Python code
- `terraform fmt` + `terraform validate` for IaC
- Deploy Lambda/API and infrastructure on main
- Frontend deploys to S3 and invalidates CloudFront

> **Security:** Never commit AWS credentials. Use OIDC for GitHub Actions to assume AWS roles.

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
