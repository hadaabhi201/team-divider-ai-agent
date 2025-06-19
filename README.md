# Istio on Minikube using Terraform

This project sets up **Istio service mesh** on a **Minikube cluster** using **Terraform**. It creates a namespace with Istio sidecar injection enabled and installs Istio using the `istioctl` CLI.

---

## 🛠 Prerequisites

### General Tools
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Istio CLI (istioctl)](https://istio.io/latest/docs/setup/getting-started/#download)

### Local Environment (Windows)
- **Operating System:** Windows 10/11
- **Minikube:** [Install Guide](https://minikube.sigs.k8s.io/docs/start/)
- **Docker Desktop:** [Install Docker](https://www.docker.com/products/docker-desktop/)

---

## 🚀 Start Minikube (Profile: `minikube-dev`)

Ensure Docker Desktop is **installed and running** before proceeding.

### Step-by-step:
1. Open **PowerShell** as Administrator
2. Run the following:

```powershell
minikube start --driver=docker --profile=minikube-dev --cpus=4 --memory=4096