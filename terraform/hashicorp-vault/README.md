# 🔐 Accessing HashiCorp Vault in Kubernetes

This guide explains how to access the Vault server deployed in Kubernetes using:

- ✅ Direct Access to Vault(web based)
- ✅ Vault CLI (via pod shell)
- ✅ Vault UI (Web Interface)

---

## 📦 Prerequisites

- Kubernetes cluster (e.g., Minikube)
- `kubectl` installed and configured
- Vault deployed and running
- `vault_user_config.sh` file available (contains admin credentials)
- This project requires the [`jq`](https://stedolan.github.io/jq/) CLI tool for JSON parsing during Vault initialization.
  - Install with:
    - `sudo apt install jq` (Linux)
    - `brew install jq` (macOS)
    - [Download jq for Windows](https://github.com/stedolan/jq/releases) and add it to your system PATH or use it directly in the script


---
## 🔗 Direct Access to Vault (Development Only)

> ⚠️ **Note**: This setup is strictly for local development and should **NOT** be used in production environments. Vault and Postgres are exposed via Istio Gateway to simplify developer workflows.

### 📌 Steps

1. **Add Entry to Your `hosts` File**  
   Add the following line to your `/etc/hosts` (Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts` (Windows) file:
   127.0.0.1 team-divider.vault


2. **Access Vault UI**  
Open [http://team-divider.vault](http://team-divider.vault) in your browser.

3. **Fetch Vault Credentials**  
Locate the `admin` username and password from the `vault_user_config.sh` file located in the `scripts/` folder:
```bash
cat scripts/vault_user_config.sh

Log in via Vault UI
Use the userpass method and the credentials you just grabbed to log in.

---

## 🚪 Step 1: Port Forward the Vault Service

Run this in a new terminal:

```bash
kubectl port-forward service/vault 8200:8200 -n vault
```

> Replace `vault` with your actual Vault service name and namespace if different.

---

## 💻 Accessing Vault via Command Line (CLI)

### 🧭 Step 2: Enter the Vault Pod Shell

```bash
kubectl exec -n vault -it vault-0 -- /bin/sh
```

> Replace `vault-0` with your actual pod name if different.

---

### 🔑 Step 3: Set Vault Address

Inside the pod shell, run:

```sh
export VAULT_ADDR=http://localhost:8200
```

> ❗ **Why is this needed?**\
> The `vault` CLI is just a client — it needs to know where the Vault server is running.\
> `VAULT_ADDR` points the CLI to the correct URL (in this case, the Vault server on the same pod at port 8200).\
> If not set, you'll see an error like:
>
> ```
> Error determining Vault address. Please set VAULT_ADDR environment variable.
> ```

---

### 🔐 Step 4: Get the Admin Password from `vault_user_config.sh`

On your local machine, run:

```bash
source ./scripts/vault_user_config.sh
echo $VAULT_ADMIN_USERNAME  # usually 'admin'
echo $VAULT_ADMIN_PASSWORD  # this is the password
```

Use these credentials for login in the next step.

---

### 🔓 Step 5: Login Using the `userpass` Auth Method

Inside the pod shell:

```sh
vault login -method=userpass username=admin password=your-password-from-script
```

Or use the environment variables:

```sh
vault login -method=userpass username=$VAULT_ADMIN_USERNAME password=$VAULT_ADMIN_PASSWORD
```

---

### ✅ Step 6: Verify Login

```sh
vault token lookup
vault kv list secret/
```

---

## 🌐 Accessing Vault via Web UI

1. Open your browser and go to:

   ```
   http://localhost:8200
   ```

2. Use **Userpass** login.

> 📝 **Note for Devs**:\
> Grab the admin username and password from the `vault_user_config.sh` file:
>
> ```bash
> export VAULT_ADMIN_USERNAME=admin
> export VAULT_ADMIN_PASSWORD=somepassword
> ```

---

## 🛑 Stop Port Forwarding

To stop port forwarding:

```bash
Ctrl + C
```

---

## 📎 References

- [https://developer.hashicorp.com/vault](https://developer.hashicorp.com/vault)
- [https://www.vaultproject.io/docs/commands](https://www.vaultproject.io/docs/commands)
- [https://www.vaultproject.io/docs/auth/userpass](https://www.vaultproject.io/docs/auth/userpass)
