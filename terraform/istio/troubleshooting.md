# 🚑 Helm Release Import Troubleshooting Guide

## ❗ Problem

You encounter the following error while running `terraform apply`:

```
Error: cannot re-use a name that is still in use
```

This typically happens when Terraform tries to create a Helm release that **already exists** in the cluster, but it **doesn’t know** about it yet (because it was installed manually or via another tool).

---

## ✅ Solution: Import the Existing Helm Release

### 1. 🔍 Identify the Release

If you defined this in Terraform:

```hcl
resource "helm_release" "istio_base" {
  name      = "istio-base"
  namespace = "istio-system"
  ...
}
```

Then the Helm release already exists in that namespace.

---

### 2. 🛠 Import the Release into Terraform

Run the following in your terminal:

```bash
terraform import helm_release.<resource_name> <namespace>/<release_name>
```

Examples:

```bash
terraform import kubernetes_namespace.team_divider team-divider
terraform import helm_release.istio_base istio-system/istio-base
terraform import helm_release.istiod istio-system/istiod
terraform import helm_release.istio_gateway istio-system/istio-ingress

```

> Replace `<resource_name>` with the actual name used in your `.tf` file.

---

### 3. ✅ Run Terraform Normally

Once the import is successful:

```bash
terraform plan
terraform apply
```

---

## 🧠 Tips

- Always match the imported release names with those used in Terraform.
- You only need to import once — after that, Terraform will manage the release.
- If a release was **partially created** via Helm or CI/CD, make sure the values used in Terraform match the existing state, or Terraform may show differences.
