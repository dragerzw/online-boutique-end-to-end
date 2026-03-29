# Architecture Deep-Dive: AWS EKS Modernization

This document provides a detailed technical breakdown of the Online Boutique's modernization onto **AWS EKS v1.35**. It covers the infrastructure architecture, security posture, and the CI/CD lifecycle from a senior DevSecOps engineer's perspective.

---

## 🏗️ 1. Infrastructure & Networking
The infrastructure is provisioned using **Terraform (v1.10+)** following a modular architecture.

### Cloud Networking (VPC)
- **Isolated Subnetting:** Nodes are deployed in **Private subnets** to ensure they are not directly exposed to the internet. 
- **Control Plane Access:** The EKS API endpoint is currently configured for **Public Access** for ease of development and CI/CD integration. 
- **NAT Gateways:** Outbound traffic from private nodes is managed via an elastic NAT gateway to facilitate image pulls and external API communication.
- **Availability Zones:** Multi-AZ deployment across 2 zones for high availability of microservice replicas.

### IAM & Security
- **OIDC Identity Provider:** Configured an EKS OIDC provider to enable **IAM Roles for Service Accounts (IRSA)**. 
- **Least Privilege:** The AWS Load Balancer Controller and other cluster components use scoped IAM roles rather than node-level instance profiles.
- **Authentication:** GitHub Actions identifies itself to AWS via an OIDC token, eliminating the risk of leaked long-lived IAM Access Keys.

---

## 🛡️ 2. DevSecOps & CI Pipeline
Our CI pipeline in **GitHub Actions** acts as a security gate for the entire system.

### Build Lifecycle
1.  **Multi-Platform Build:** Support for `linux/amd64` builds using Docker Buildx.
2.  **Container Optimization:** Microservices like `cartservice` utilize **Chiseled .NET images** and **Distroless** base images where possible to minimize the attack surface.
3.  **Mandatory Security Scan (Trivy):** 
    - Scans every image for OS and Language-specific vulnerabilities (CVEs).
    - Hard failure on `HIGH` or `CRITICAL` findings.
    - Risk acceptance is strictly version-controlled via `.trivyignore`.
4.  **Tagging Strategy:** Semantic versioning combined with full Git SHA tagging for absolute traceability from ECR back to the source code.

---

## 📈 3. Continuous Delivery (GitOps)
We utilize a **GitOps Pull-Based Model** via **ArgoCD**, moving away from "push-and-pray" deployment methods.

### GitOps Workflow
1.  **Declarative Manifests:** All Kubernetes resources are managed as **Helm Charts**.
2.  **ArgoCD Sync:** A dedicated `cicd` service account monitors the repository for changes. 
3.  **Path-Based Routing (UI Only):** The cluster is configured to serve the ArgoCD UI under a dedicated `/argocd` prefix for ingress isolation. However, the REST API remains accessible at the root (`/api/v1`) to maintain compatibility with standard CI/CD automation and external tools.
4.  **Automatic Drift Correction:** ArgoCD continuously reconciles the cluster state with the Git repository, automatically correcting any manual `kubectl` changes.
5.  **Load Balancing:** The **AWS Load Balancer Controller** dynamically provisions Network Load Balancers (NLBs) for the ArgoCD UI and Application Frontends.

---

## 📊 4. Observability & Monitoring
Monitoring is centralized using the **Kube-Prometheus-Stack**.

- **Prometheus:** Collects metrics from microservices via gRPC and HTTP probes.
- **Grafana:** Pre-provisioned dashboards for cluster health, node performance, and pod lifecycle monitoring.
- **Alertmanager:** Configurable alerts for resource exhaustion or pod failure loops.

---

## 🛠️ Microservice Breakdown

| Service | Language | Core Responsibility |
| :--- | :--- | :--- |
| **Frontend** | Go | E-commerce web gateway |
| **Cart Service** | C# / .NET 10 | Redis-backed shopping cart management |
| **Checkout** | Go | Order orchestration and payment processing |
| **Product Catalog** | Go | Inventory management and product search |
| **Ad Service** | Java | Context-aware advertisement delivery |
| **Shipping** | Go | Shipping cost estimation and mock fulfillment |

---
*Developed as a showcase of modern Cloud-Native Engineering practices.*
