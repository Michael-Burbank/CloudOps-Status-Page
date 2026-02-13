# CloudOps Status Page

CloudOps Status Page is a cloud-native status page project that I am using to sharpen my AWS Solutions Architect, Infrastructure as Code, and CloudWatch skills. The initial focus is simple and very practical: **monitor the public Arizona State Parks & Trails website (<https://azstateparks.com>)** from AWS and expose that health on a small status page.

Over time this repository will grow into a reusable, open-source pattern for monitoring multiple endpoints (websites and APIs) using AWS-native services and modern DevOps practices.

---

## Current Scope (Phase 1)

Right now the project is intentionally narrow so I can get the fundamentals right:

- **Single endpoint:** `https://azstateparks.com`
- **Health checks:** periodic HTTP GET, tracking status code and latency
- **Serverless monitoring pipeline:**
  - **Amazon EventBridge:** schedule that triggers the health check
  - **AWS Lambda:** Python function that performs the check and emits metrics/logs
  - **Amazon CloudWatch Logs:** request + result logging for troubleshooting
  - **Amazon CloudWatch Metrics & Alarms:** basic availability/latency alarms
- **Infrastructure as Code:** Terraform manages all AWS resources for the checker

The public status UI and multi-endpoint support will be layered on top of this solid, observable core.

---

## Planned Features

As the project evolves, the goal is to support:

- Monitor **multiple endpoints** (websites, APIs, public services)
- Configurable check frequency (for example every 1, 5, or 15 minutes)
- Downtime detection based on timeouts, non-2xx responses, or slow latency
- Simple, professional status page (HTML/CSS/JS) hosted on **S3 + CloudFront**
- Historical incident view backed by **DynamoDB**
- Alerting via **SNS** (email, Slack, or similar later)
- Optional "ops toolbox" EC2 instance managed with **Ansible** for experiments
- CI/CD using **GitLab CI** (with mirroring to GitHub) for tests and deployments

I am deliberately building this in small, well-defined phases so it mirrors the kind of incremental CloudOps work I will be doing professionally.

---

## Architecture (Phase 1)

Current serverless monitoring flow:

```text
EventBridge schedule (every N minutes)
        ↓
AWS Lambda (Python health check for https://azstateparks.com)
        ↓
CloudWatch Logs (raw results + debugging)
        ↓
CloudWatch Metrics & Alarms (availability/latency signals)
```

Key ideas:

- **EventBridge** handles scheduling instead of cron on a VM.
- **Lambda** keeps the checker lightweight, scalable, and low-cost.
- **CloudWatch Logs** provide detailed traces for each run.
- **CloudWatch Metrics & Alarms** turn raw checks into actionable signals.

Future phases will introduce DynamoDB for structured history and S3/CloudFront for the public status page.

---

## Tech Stack

### AWS Services\*\*

- Lambda (Python health-check function)
- EventBridge (scheduled triggers)
- CloudWatch Logs, Metrics, Alarms
- DynamoDB (planned for status history)
- S3 + CloudFront (planned for frontend hosting)
- IAM (least-privilege roles for Lambda and related services)

### Infrastructure as Code & Automation\*\*

- Terraform for provisioning AWS resources
- Ansible (planned) for configuring any EC2-based "ops toolbox" instances
- GitLab CI (planned) for automated tests, Terraform validation, and deployments

### Languages & Tools\*\*

- Python 3.x
- HCL (Terraform)
- Bash / shell scripts where helpful

---

## Getting Started (Work in Progress)

> **Note:** This repository is under active development. The exact file paths and variable names may change as I iterate. The steps below describe the intended workflow.

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-username/cloudops-status-page.git
   cd cloudops-status-page
   ```

2. **Configure AWS credentials**

   Use an IAM user or role with least-privilege permissions suitable for creating the resources managed by Terraform in your chosen AWS account.

3. **Review Terraform configuration**
   - Check the Terraform files under `infra/` (or the directory you use for IaC).
   - Update variables such as region, tags, and any naming conventions.

4. **Initialize and apply Terraform**

   ```bash
   cd infra
   terraform init
   terraform plan
   terraform apply
   ```

5. **Verify the health checker**
   - Open the AWS console and navigate to **CloudWatch Logs** to confirm that the Lambda function is running on schedule.
   - Check CloudWatch metrics and any defined alarms to see availability and latency for `https://azstateparks.com`.

As the frontend status page and multi-endpoint configuration are implemented, this section will be updated with additional steps.

---

## Roadmap

1. **Phase 1. Single-endpoint monitoring (current focus)**
   - Lambda + EventBridge health checker for `https://azstateparks.com`
   - CloudWatch Logs, metrics, and basic alarms

2. **Phase 2. Persistence and history**
   - Store check results and incidents in DynamoDB
   - Build simple APIs to query recent and historical status

3. **Phase 3. Public status page**
   - Static frontend on S3 + CloudFront
   - Live status indicator and recent incident history

4. **Phase 4. Multi-endpoint configuration**
   - Move endpoint definitions into a configuration file or DynamoDB table
   - Support additional public endpoints via config or pull requests

5. **Phase 5. Automation and hardening**
   - CI/CD pipelines with GitLab CI (linting, tests, Terraform validation)
   - IAM tightening, logging improvements, and helpful CloudWatch dashboards

---

## Why this project exists

CloudOps Status Page is both a useful tool and a learning vehicle. It is designed to:

- Practice **AWS Solutions Architect** patterns on a realistic, but manageable, problem.
- Use **Terraform** and other IaC tools to manage real infrastructure end-to-end.
- Get hands-on with **CloudWatch** for logs, metrics, alarms, and dashboards.
- Build something I can talk about concretely when discussing cloud operations and monitoring work.

If you have ideas, suggestions, or want to adapt this pattern for your own endpoints, feel free to open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License.
