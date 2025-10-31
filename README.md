

# Employee Management System

[![Go](https://img.shields.io/badge/Go-1.19-blue?logo=go&logoColor=white)](https://golang.org)
[![React](https://img.shields.io/badge/React-18-green?logo=react&logoColor=white)](https://reactjs.org)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS%201.34-purple?logo=kubernetes&logoColor=white)](https://aws.amazon.com/eks/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker&logoColor=white)](https://docker.com)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

**Full-stack CRUD application** to **add and view employee details**.

- **Backend**: Go Fiber API + PostgreSQL
- **Frontend**: React SPA with Nginx
- **Infra**: AWS EKS (Kubernetes) + Terraform + EBS GP3
- **Local Dev**: Docker Compose (1 command)
- **Production**: 1-Click GitHub Actions (EKS + Deploy + NLB)

---

## Features
- Add Employee: Name, Email, Salary, Department
- View All: Paginated table + Search
- Responsive UI: Mobile-first React
- REST API: `/api/employees` (GET/POST)
- Health Checks: K8s Liveness & Readiness Probes
- Horizontal Scaling: 2x Frontend Replicas
- Persistent Storage: 10Gi EBS GP3 Volume
- Load Balancer: AWS NLB (Internet-facing)

---

## Architecture

## Architecture

```ascii
┌──────────────────┐    ┌──────────────┐
│  AWS NLB (K8s)   │◄──►│ React+Nginx  │
│   frontend-lb    │    │   (Port 80)  │
└──────────────────┘    └──────────────┘
                             │
                             ▼
┌──────────────────┐    ┌──────────────┐
│  K8s Services     │◄──►│ Go Fiber     │
│  ClusterIP        │    │   (Port 8080)│
└──────────────────┘    └──────────────┘
                             │
                             ▼
                    ┌──────────────┐
                    │ PostgreSQL   │
                    │ 15-alpine    │
                    │ EBS GP3 PVC  │
                    └──────────────┘
```


- **Namespace**: `default`
- **Security**: Non-root containers, Secrets
- **Probes**: Startup, Liveness, Readiness
- **Resource Limits**: Prevent OOM

---

## Quickstart: Local (Docker Compose)
```bash
git clone https://github.com/shubhamch71/techv-app
cd techv-app
docker compose up -d
```

Open: http://localhost:3000

Teardown:
```bash
docker compose down -v  # -v wipes DB
```

### Production: 1-Click GitHub Actions

**Zero AWS Console. Fully automated.**

| Workflow | Purpose | Trigger |
|----------|--------|---------|
| **1. Create Backend** | S3 + DynamoDB for Terraform state | `CREATE BACKEND` |
| **2. Create EKS** | VPC + EKS + **EBS CSI Auto-Install** | `CREATE INFRA` |
| **3. Deploy App** | **K8s Deploy** + **NLB URL** + **kubeconfig Download** | `DEPLOY APP` |
| **App Destroy** | Delete app (keep EKS) | `DELETE APP` |
| **EKS Destroy** | Delete EKS + VPC | `DELETE EKS` |
| **Nuclear Destroy** | **Delete everything** | `DESTROY EVERYTHING` | 
- --


Deploy in 5 Minutes

Fork → Settings → Secrets → Add:
```
AWS_ROLE_ARN=arn:aws:iam::<account-i>>:role/github-role
AWS_REGION=<region-name>
EKS_CLUSTER_NAME=<cluster-name>
AWS_ACCOUNT_ID=
TF_BACKEND_BUCKET=<bucket-name>
TF_BACKEND_TABLE=<table-name>
```
Run 2. Create EKS → CREATE INFRA → Wait 8 mins
Run 3. Deploy App → DEPLOY APP → Get NLB URL
Local Access: Download kubeconfig → kubectl port-forward

App Live: http://k8s-frontend-lb-xxxx.elb.amazonaws.com

**Kustomize**

Our Structure
```
kustomise/base/
├── storage.yaml         # EBS GP3 PVC (10Gi)
├── postgres.yaml        # Stateful DB + Init Chown
├── backend.yaml         # Go Deployment + Probes
├── frontend.yaml        # React 2x Replicas + Nginx Proxy
├── frontend-lb.yaml     # NLB (Internet-facing)
└── kustomization.yaml   # Resource list + patches
```

Key Patterns:

1) Dynamic Secrets: Created in CI (postgres-secret)
2) API Proxy: Nginx routes /api/ → backend-service:8080
3) Init Wait: Frontend waits for backend DNS
4) Probes: /employees (backend), / (frontend)
5) Resource Limits: CPU/Memory caps

Apply:
```
kustomize build kustomise/base | kubectl apply -f -
```

## GitHub Actions: Modular & Safe

Each workflow is **idempotent** and **focused**:

| File | Purpose |
|------|---------|
| `create-backend.yaml` | S3 + DynamoDB (Terraform backend) |
| `create-eks.yaml` | VPC + EKS + **EBS CSI + Pod Identity** |
| `3-app.yaml` | Deploy app + **wait for PVC/NLB** + **download kubeconfig** |
| `app-destroy.yaml` | Delete app only |
| `eks-destroy.yaml` | Delete EKS + VPC |
| `destroy.yaml` | **Nuclear**: Delete all (safe order) |

**Key Features**:
- **Robust EBS CSI wait** (loop until `Available`)
- **Pod Identity** (EKS 1.34+)
- **Idempotent IAM role creation**
- **Dynamic secrets** (no Git leak)
- **NLB URL detection**
- **Artifact**: `kubeconfig.yaml`



<!-- ## Roadmap

- [ ] **ALB + HTTPS** with ACM & custom domain
- [ ] **ArgoCD** for GitOps CD
- [ ] **Monitoring**: Prometheus + Grafana
- [ ] **CI Tests**: Go + React
- [ ] **JWT Auth**
- [ ] **Helm Chart** (optional) -->

---

## Contributing

1. **Fork** → Make changes
2. **Test locally**: `docker compose up`
3. **Open PR**

**Star if helpful!**

---

*Built with* by [Shubham Chaudhari](https://github.com/shubhamch71)  
*Oct 2025*
