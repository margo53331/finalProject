# DevOps Deployment & CI/CD Pipeline: Name Generator Application

> [!NOTE]
> **Project Status:** Production-ready continuous delivery pipeline configured for AWS EKS, AWS ECR, and MongoDB.

[![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue?logo=githubactions)](https://github.com)
[![Cluster](https://img.shields.io/badge/Orchestration-AWS%20EKS-orange?logo=kubernetes)](https://aws.amazon.com/eks/)
[![Database](https://img.shields.io/badge/Database-MongoDB-green?logo=mongodb)](https://www.mongodb.com/)

An end-to-end DevOps deployment solution for containerizing and deploying a multi-tier web application (`namegen`) onto **AWS Elastic Kubernetes Service (EKS)**.

---

## Architecture Overview

![Architecture & CI/CD Diagram](./diagrams/architecture-pipeline.png)

### Cluster Infrastructure (`namegen` Namespace)

* **Client Tier:**
  * External user traffic enters the cluster via **HTTP** requests routed to an **AWS Elastic Load Balancer (ELB)**.
* **Application Tier:**
  * **App Service (`Type: LoadBalancer`):** Exposes application traffic externally and routes incoming requests.
  * **App Deployment (`namegen-app`):** Manages 3 stateless Pod replicas for high availability and zero-downtime rolling updates.
* **Database Tier:**
  * **MongoDB Service (`Type: ClusterIP:27017`):** Provides internal cluster communication for database queries.
  * **StatefulSet (`mongodb`):** Ensures stable network identities and persistent storage binding.
  * **Persistent Volume Claim (PVC):** Dynamically provisions persistent storage backed by **AWS EBS**.
* **Configuration Tier:**
  * **ConfigMap (`namegen-config`):** Injects non-sensitive environment variables (e.g., `NODE_ENV`, `PORT`).
  * **Secret (`mongodb-secret`):** Securely injects base64-encoded credentials and URI connection strings.

---

## Pipeline Workflow

1. **`git push`** $\rightarrow$ Developer pushes code changes to the `main` branch.
2. **Authentication** $\rightarrow$ Workflow authenticates securely with AWS using IAM secrets.
3. **Container Build** $\rightarrow$ Docker builds the container image specified by the `Dockerfile`.
4. **Registry Push** $\rightarrow$ Image is pushed to **AWS Elastic Container Registry (ECR)**.
5. **Cluster Rollout** $\rightarrow$ Executes `kubectl apply` and triggers a rolling update on **AWS EKS**.

---

## Directory Layout

```text
devops/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD pipeline definition
├── diagrams/
│   ├── architecture-pipeline.drawio # Draw.io source file
│   └── architecture-pipeline.png    # High-resolution export
├── k8s/
│   ├── 00-namespace.yaml       # K8s Namespace definition
│   ├── 01-configmap.yaml       # Environment configuration
│   ├── 02-secret.yaml          # Encrypted database credentials
│   ├── 03-mongodb-pvc.yaml     # AWS EBS Persistent Volume Claim
│   ├── 04-mongodb.yaml         # StatefulSet + ClusterIP Service
│   └── 05-app-deployment.yaml  # App Deployment + LoadBalancer Service
├── src/                        # Application source code
├── Dockerfile                  # Container build instructions
└── README.md                   # Project documentation
```

---

## Required GitHub Secrets

Configure these environment secrets under **Settings** $\rightarrow$ **Secrets and variables** $\rightarrow$ **Actions**:

| Secret Name | Description | Example / Format |
| :--- | :--- | :--- |
| `AWS_ACCESS_KEY_ID` | AWS IAM Access Key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM Secret Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | Target AWS Deployment Region | `us-east-1` |
| `ECR_REPOSITORY` | AWS ECR Repository Name | `namegen-app` |
| `EKS_CLUSTER_NAME` | Target AWS EKS Cluster Name | `namegen-eks-cluster` |

---

## Deployment Instructions

> [!IMPORTANT]
> Ensure your local environment has `aws-cli`, `kubectl`, and `docker` installed prior to running manual setup commands.

### 1. Connect local `kubectl` to AWS EKS

```bash
aws eks update-kubeconfig --region <AWS_REGION> --name <EKS_CLUSTER_NAME>
```

### 2. Apply Kubernetes Manifests

```bash
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/01-configmap.yaml
kubectl apply -f k8s/02-secret.yaml
kubectl apply -f k8s/03-mongodb-pvc.yaml
kubectl apply -f k8s/04-mongodb.yaml
kubectl apply -f k8s/05-app-deployment.yaml
```

### 3. Verify Deployment Status

```bash
# Check all active pods, deployments, and services in the namespace
kubectl get all -n namegen

# Retrieve the external LoadBalancer DNS address
kubectl get svc app-service -n namegen
```

---

## Deployment Verification Checklist

- [x] Dockerfile containerization and multi-stage build setup
- [x] AWS ECR image repository configuration
- [x] AWS EKS cluster and node group provisioning
- [x] Kubernetes declarative manifests (`k8s/*.yaml`)
- [x] Stateful MongoDB persistent storage configuration (AWS EBS PVC)
- [x] GitHub Actions automated CI/CD continuous deployment workflow

---

> To view live application logs across all active pods, run:  
> `kubectl logs -f -l app=namegen-app -n namegen`