provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "null_resource" "vault_login" {
  provisioner "local-exec" {
    command = "bash ${path.module}/../scripts/vault_login.sh ${var.vault_addr} ${var.vault_username} ${var.vault_password}"
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "kubernetes_namespace" "database" {
  metadata {
    name = "database"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "helm_release" "postgres" {
  name       = "postgres"
  namespace  = kubernetes_namespace.database.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "12.5.7"

  # Authentication configuration
  set {
    name  = "auth.postgresPassword"
    value = random_password.postgres_root.result
    # value = var.postgres_password
  }
  set {
    name  = "auth.username"
    value = var.db_root_username
  }

  set {
    name  = "auth.password"
    value = random_password.postgres_root.result
    # value = var.postgres_password
  }

  set {
    name  = "auth.database"
    value = var.db_name
  }

  # ⚠️ POC setup: Expose the PostgreSQL service as LoadBalancer
  # DO NOT USE IN PRODUCTION — Use internal services and secure access instead
  set {
    name  = "primary.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "primary.persistence.enabled"
    value = "true"
  }

  set {
    name  = "primary.persistence.size"
    value = "200Mi"
  }

  set {
    name  = "primary.persistence.storageClass"
    value = "standard"
  }

  depends_on = [
    kubernetes_namespace.database,
    vault_kv_secret_v2.postgres_root_secret
  ]
}
