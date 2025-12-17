# Automated Multi-Cloud Orchestrated with Terraform + Ansible
---
## 1. Description

The following infrastructure simulates a distributed corporate environment. The project connects a **Frontend** application hosted on **AWS** (Public Cloud) with a secure, legacy database hosted on **Azure**.

The implementation of a **Site-to-Site VPN Tunnel (IPsec IKEv2)** allows both clouds to communicate privately and securely over the internet without exposing sensitive data.

The entire lifecycle is managed via **GitOps** and Infrastructure as Code (IaC), using Terraform for provisioning and Ansible for configuration.

<img width="100%" alt="Pipeline Diagram" src="https://github.com/user-attachments/assets/35e3f570-3e3f-4699-a87f-cec0d4f29316" />

### Automated Pipeline Flow:
1. **Provisioning (Slow Path):** Terraform creates networks in AWS and Azure in parallel.
2. **Handshake:** A scripted handshake exchanges Public IPs between clouds to establish the VPN tunnel.
3. **State Sharing:** The inventory and topology data are securely uploaded to an S3 bucket.
4. **Configuration (Fast Path):** Once infrastructure is ready, **Ansible** is automatically triggered to configure servers and deploy the Python/Flask application.

---
## 2. Prerequisites & Configuration

### A. Secrets Configuration
Before running, configure the following "Secrets" in your GitHub repository settings:

* **AWS (IAM User):** Create an IAM user with `AdministratorAccess`.
    * `AWS_ACCESS_KEY_ID`
    * `AWS_SECRET_ACCESS_KEY`
* **Azure:** `AZURE_CREDENTIALS` (Service Principal JSON), `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`.
* **Network:** `VPN_SHARED_KEY` (Strong password for the VPN tunnel).
* **Access:** `SSH_KEY_AWS` & `SSH_KEY_AZURE` (Private key content for Ansible access).

### B. Terraform Backend Setup (Critical)
Since S3 bucket names are globally unique and the project uses a remote backend for state persistence, **you must configure your own backend** before deploying.

1. **Create Resources:** Manually create an S3 Bucket and a DynamoDB Table (named `terraform-locks`) in your AWS account.
2. **Update Code:** Open `aws/main.tf` and `proyecto-AZURE/main.tf`.
3. **Replace Bucket Name:** Find the `backend "s3"` block and change the `bucket` value to YOUR bucket name.

```hcl
  backend "s3" {
    bucket         = "YOUR-BUCKET-NAME" #Update this line
    key            = "aws-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

```

---

## 3. Installation and Deployment

This project does not require installation of tools on your local machine; everything runs automatically through **GitHub Actions** pipelines.
This project uses a **Chained Workflow** strategy to optimize deployment times.

### How to Deploy

1. **Create a Branch:** Create a feature branch (e.g., `feature/update-infra`).
2. **Push Changes:** Commit and push your changes to the cloned repository.
3. **Pull Request:** Open a Pull Request (PR) to merge into `main`.
4. **Merge:** Once approved, merge the PR.entonces es oportuno mencionar est

### Automatic Trigger Logic

Upon merging to `main`, the automation starts:

* **Scenario A (Infrastructure Changes):**
1. GitHub triggers **"Infrastructure Deployment"**.
2. Terraform applies changes to AWS/Azure.
3. On success, it **automatically triggers** the second workflow.
4. **"Configure and Deploy Application"** runs to configure the new servers.


* **Scenario B (App Code Changes):**
1. GitHub detects changes only in `app/` or `ansible/`.
2. It skips Terraform and **immediately triggers** **"Configure and Deploy Application"**.
3. Deployment completes in minutes.

*Note: You can also trigger workflows manually via the "Actions" tab using the `workflow_dispatch` button.*


### Resource Destruction

To destroy resources and avoid costs:

1. Go to the **Actions** tab.
2. Select the workflow **"Infrastructure Destruction"**.
3. Click **Run Workflow**.

---

## 4. Result

![Screenshot_2025-12-11-21-03-27-643_com android chrome(2)](https://github.com/user-attachments/assets/067439d3-667f-4fe3-b5d8-34b8e3bf3242)

Once deployed, the system features:

* **Web Access:** Access the Payroll Dashboard via the Public IP of the AWS EC2 instance.
* **Zero Trust Connectivity:** The web app pulls real-time data from the Azure PostgreSQL database exclusively through the VPN tunnel (private IPs 10.x.x.x), ensuring traffic never traverses the public internet unsecured.
* **State Persistence:** Infrastructure state is securely locked and stored in the remote S3 Backend.
