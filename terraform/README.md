# Infrastructure Deployment Guide

This repository provisions the infrastructure using **Terraform**, with a clearly defined module dependency order.

## 🏗️ Module Dependencies

- **Istio** must be deployed **first**.
- **Vault** depends on Istio, so it must be deployed **after Istio**.
- **Postgres** depends on Vault, so it must be deployed **after Vault**.

---


## 🚀 Deployment Steps

### 1. Deploy Istio

```bash
cd terraform/istio
terraform init
terraform apply
```

---

### 2. Deploy Vault (after Istio)

```bash
cd ../hashicorp-vault
terraform init
terraform apply
```

---

### 3. Deploy Postgres (after Vault)

- Create the database

```bash
cd ../postgres/create_db
terraform init
terraform apply
```
- Create the db users

```bash
cd ../postgres/create_users
export VAULT_ADDR="http://team-divider.vault"
vault login %TOKEN%  // grab the token from hashicorp repo in vault-init.json
terraform init
terraform apply
```

---

## ✅ Notes

- Ensure your Kubernetes context is properly set (e.g., via Minikube or your cloud provider).
- If you're using **Minikube** with LoadBalancer services, you must run:

```bash
minikube tunnel
```

- Vault stores secrets for Postgres users, which are consumed by services via Helm charts.
- Each module is self-contained and managed independently for better control and separation of concerns.
