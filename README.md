# Automated Multi-Cloud Orchestrated with Terraform + Ansible
---
## 1. Description

The following infrastructure has been designed to simulate a distributed corporate environment. The project connects a **Frontend** application hosted on **AWS** (Public Cloud) with a secure, legacy database hosted on **Azure**.

The implementation of a **Site-to-Site VPN Tunnel (IPsec IKEv2)** allows both clouds to communicate privately and securely over the internet without exposing sensitive data.

The entire lifecycle of the infrastructure is managed via **GitOps** and Infrastructure as Code (IaC), using Terraform for provisioning and Ansible for configuration.

<img width="100%" height="1536" alt="Gemini_Generated_Image_ffmaamffmaamffma" src="https://github.com/user-attachments/assets/35e3f570-3e3f-4699-a87f-cec0d4f29316" />


### Pipeline Flow:
1. **Terraform** creates networks in AWS and Azure in parallel.
2. A handshake is performed between AWS and Azure to exchange IPs and establish the VPN.
3. **Ansible** configures the servers and deploys the Python/Flask application.
4. The final result is a fully functional distributed system.

---
## 2. Installation and Execution

This project does not require installation of tools on your local machine; everything runs automatically through **GitHub Actions** pipelines.

### A. Prerequisites (Secrets Configuration)
Before running, you need to configure the following "Secrets" in your repository settings on GitHub:

* **AWS (IAM User):** Create an IAM user with programmatic access and `AdministratorAccess` permissions.
    * `AWS_ACCESS_KEY_ID`: The IAM user's access key ID.
    * `AWS_SECRET_ACCESS_KEY`: The IAM user's secret access key.

* **Azure:** `AZURE_CREDENTIALS` (Service Principal JSON), `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`.

* **Network:** `VPN_SHARED_KEY` (Strong password for the VPN tunnel).

* **Access:** `SSH_KEY_AWS` (Contents of the private .pem key for Ansible).

### B. Execution / Deployment
To deploy the infrastructure, simply **Push** to the main branch:

    git add .
    git commit -m "Deploy infrastructure"
    git push origin main

This will trigger the "Full Infrastructure Deployment" workflow in the **Actions** tab of GitHub.

### C. Resource Destruction
To destroy resources and avoid costs, manually trigger the workflow:
1. Go to the **Actions** tab.
2. Select the workflow **"Infrastructure Destruction"**.
3. Click **Run Workflow**.

---

## 3. Result

![Screenshot_2025-12-11-21-03-27-643_com android chrome(2)](https://github.com/user-attachments/assets/067439d3-667f-4fe3-b5d8-34b8e3bf3242)

Once the automatic deployment is finished, the system will be operational with the following features:

* **Web Access:** You can access the simulated Payroll Dashboard through the Public IP of the EC2 instance in AWS.
* **Private Connectivity:** The web application will display real-time data (employees, salaries) pulled from the PostgreSQL database in Azure. This connection occurs exclusively through the VPN tunnel (private IPs 10.x.x.x), demonstrating a Zero Trust architecture.
* **Persistence:** Thanks to the remote Backend on S3, the state of the infrastructure remains secure and consistent across executions.
