# Online Boutique: Cloud-Native DevSecOps Modernization
 
A hardened, fully automated reference architecture that modernizes the Google Online Boutique microservices app onto AWS EKS v1.35 — implementing DevSecOps best practices, a "True Green" CI/CD pipeline, and GitOps-based continuous delivery.
 
---
 
## 📖 Table of Contents
 
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [DevSecOps & Security Posture](#️-devsecops--security-posture)
- [CI/CD & GitOps Workflow](#-cicd--gitops-workflow)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
- [Key Engineering Decisions](#-key-engineering-decisions--challenges)
- [Repository Structure](#-repository-structure)
- [Further Reading](#-further-reading)
 
---
 
## 🏗️ Architecture
 
The system architecture relies heavily on Infrastructure as Code (IaC) and a GitOps operational framework to ensure 100% reproducibility, disaster recovery readiness, and strict auditability.
 
![System Architecture Diagram](https://github.com/user-attachments/assets/1de0a970-ffb1-45ab-80cc-927dd0f9d0bc)
 
---
 
## 🧰 Technology Stack
 
| Category | Technology | Purpose |
|---|---|---|
| Cloud Provider | AWS | VPC, EKS, ECR, IAM, Application Load Balancers |
| Orchestration | Kubernetes (EKS v1.35) | Container scheduling, scaling, and management |
| Infrastructure as Code | Terraform | Immutable infrastructure provisioning |
| CI/CD | GitHub Actions | Continuous Integration, Testing, and Image Builds |
| Continuous Delivery | ArgoCD | GitOps controller for cluster state reconciliation |
| Security Scanning | Aqua Security Trivy | Container image vulnerability scanning (CVEs) |
| Observability | Prometheus & Grafana | Cluster and application metrics monitoring |
| Workloads | Go, .NET, Node.js, Python | Polyglot microservices architecture |
 
---
 
## 🛡️ DevSecOps & Security Posture
 
This project enforces a **Security-First** and **Zero-Trust** approach at every stage of the software development lifecycle:
 
- **Shift-Left Security:** Every image must pass a mandatory Trivy High/Critical scan before being pushed to Amazon ECR.
- **Secretless Authentication:** Replaces static, long-lived AWS IAM Access Keys with GitHub Actions OIDC (OpenID Connect) identity tokens for temporary, scoped AWS credentials.
- **Risk Management:** Implemented a refined, version-controlled `.trivyignore` manifest to explicitly manage, document, and accept known risks in upstream base images without compromising the pipeline's hard-fail gates.
- **Principle of Least Privilege:** EKS pods are configured to use IAM Roles for Service Accounts (IRSA), restricting AWS API access to only the necessary resources on a per-pod basis.
 
---
 
## 🔄 CI/CD & GitOps Workflow
 
### CI — Continuous Integration (GitHub Actions)
Developers push code → GitHub Actions runs unit tests → Builds Docker images → Scans images with Trivy → Pushes secure images to Amazon ECR.
 
### Manifest Sync
The CI pipeline automatically updates the Kubernetes deployment manifests in the repository with the new image tags.
 
### CD - Continuous Delivery (ArgoCD)
ArgoCD, running inside the EKS cluster, detects drift between the Git repository state and the live cluster state, automatically synchronizing the deployment to reflect the latest secure build.
 
---
 
## ✅ Prerequisites
 
Before provisioning this environment, ensure you have the following installed and configured:
 
- AWS CLI configured with appropriate administrative permissions
- Terraform (v1.5.0+)
- `kubectl` compatible with EKS v1.35
- A GitHub account and Personal Access Token (for ArgoCD Git access)
 
---
 
## 🚀 Getting Started
 
### 1. Clone the Repository
 
```bash
git clone https://github.com/dragerzw/online-boutique-end-to-end.git
cd online-boutique-end-to-end
```
 
### 2. Provision Cloud Infrastructure (AWS)
 
Navigate to the Terraform directory to initialize and apply the infrastructure.
 
> ⚠️ **Note:** This will incur AWS charges.
 
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```
 
### 3. Configure Local Cluster Access
 
Once Terraform completes, update your local kubeconfig to interact with the new EKS cluster:
 
```bash
aws eks update-kubeconfig --region us-east-1 --name online-boutique
```
 
### 4. Bootstrap GitOps (ArgoCD)
 
Deploy the ArgoCD Application manifest to initiate the GitOps synchronization of the microservices:
 
```bash
cd ..
kubectl apply -f argocd/application.yaml
```
 
### 5. Access the Application and Dashboards
 
- **Online Boutique UI:** Retrieve the LoadBalancer URL via:
  ```bash
  kubectl get svc -n default
  ```
 
- **ArgoCD UI:** Retrieve the NLB URL and the initial admin password:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d
  ```
 
- **Grafana / Prometheus:** Port-forward the monitoring services to your localhost:
  ```bash
  kubectl port-forward svc/grafana 3000:80 -n monitoring
  ```
 
---
 
## 🧠 Key Engineering Decisions & Challenges
 
Building a production-ready EKS environment presented several high-level technical challenges that required deep architectural decisions:
 
### EKS Access Entries & The "Invisible Admin"
 
- **Challenge:** Post-provisioning, the IAM identity used by Terraform was locked out of the Kubernetes API, resulting in pipeline deployment failures.
- **Solution:** Migrated away from the legacy `aws-auth` ConfigMap to the modern EKS Access Entries API (introduced in EKS v1.30+), explicitly enabling `enable_cluster_creator_admin_permissions` in Terraform for robust, native access management.
 
### Achieving a "True Green" Pipeline with Upstream Vulnerabilities
 
- **Challenge:** Upstream base images (e.g., Node.js, Python) contained "High" severity vulnerabilities (like `glibc` or `orjson`) that lacked patches, causing continuous CI pipeline failures.
- **Solution:** Established a strict **Risk Acceptance Strategy** using a `.trivyignore` file. This allows explicitly documented CVEs to pass while maintaining a hard-fail mechanism for new vulnerabilities, preventing security drift.
 
### OIDC Identity Federation over Static Credentials
 
- **Challenge:** Storing `AWS_ACCESS_KEY_ID` in GitHub Secrets is an anti-pattern and a significant security liability.
- **Solution:** Configured an AWS IAM OIDC Identity Provider establishing trust with GitHub Actions. The pipeline now requests temporary, least-privilege STS tokens, achieving a secure, "zero-secret" authentication architecture.
 
### ArgoCD API Routing Nuances
 
- **Challenge:** Automating ArgoCD syncs via GitHub Actions resulted in `404 Not Found` errors, despite configuring the correct Argo UI `rootpath`.
- **Solution:** ArgoCD's UI supports path prefixes (e.g., `/argocd`), but its gRPC/REST API expects to be served at the host root. Updated the CI/CD pipeline logic to dynamically strip path prefixes when constructing API endpoints, ensuring reliable pipeline triggers.
 
---
 
## 📂 Repository Structure
 
```
.
├── .github/
│   └── workflows/          # GitHub Actions CI/CD pipelines
├── argocd/
│   └── application.yaml    # Declarative GitOps deployment configuration
├── docs/
│   └── ARCHITECTURE.md     # Deep-dive architecture documentation
├── kubernetes/             # Kubernetes manifests for the microservices
├── src/                    # Application source code (microservices)
├── terraform/
│   ├── main.tf             # Main Terraform configuration
│   ├── vpc.tf              # Network infrastructure
│   ├── eks.tf              # Kubernetes cluster definition
│   └── iam.tf              # OIDC, IRSA, and Access Entries
├── .trivyignore            # Documented CVE risk acceptances
└── README.md
```
 
---
 
## 🧹 Teardown & Cleanup
 
> ⚠️ **Warning:** Run this when you are completely done. This will permanently destroy all provisioned AWS infrastructure and cannot be undone.
 
```bash
cd terraform
terraform destroy -auto-approve
```
 
---
 
## 📚 Further Reading
 
- [Architecture Deep-Dive](docs/ARCHITECTURE.md) — Detailed infrastructure, security, and CI/CD lifecycle overview for senior reviewers.
- [ArgoCD Application Manifest](argocd/application.yaml) — Examine the declarative GitOps configuration.
- [Terraform Modules](terraform/) — Review the Infrastructure as Code driving this environment.
 
---
 
*Built by **Drager Mandiya** — [Portfolio](https://github.com/dragerzw) · [LinkedIn](https://linkedin.com/in/dragermandiya)*
