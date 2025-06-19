resource "kubernetes_service_account" "vault_reviewer" {
  metadata {
    name      = "vault-reviewer"
    namespace = "vault"
  }
}

resource "kubernetes_cluster_role_binding" "vault_reviewer_binding" {
  metadata {
    name = "vault-reviewer-binding"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault_reviewer.metadata[0].name
    namespace = kubernetes_service_account.vault_reviewer.metadata[0].namespace
  }
}

resource "kubernetes_secret" "vault_reviewer_token" {
  metadata {
    name      = "vault-reviewer-token"
    namespace = kubernetes_service_account.vault_reviewer.metadata[0].namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.vault_reviewer.metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
}

data "kubernetes_secret" "vault_reviewer_token_data" {
  metadata {
    name      = kubernetes_secret.vault_reviewer_token.metadata[0].name
    namespace = kubernetes_secret.vault_reviewer_token.metadata[0].namespace
  }

  depends_on = [kubernetes_secret.vault_reviewer_token]
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "https://kubernetes.default.svc"
  kubernetes_ca_cert = data.kubernetes_secret.vault_reviewer_token_data.data["ca.crt"]
  token_reviewer_jwt = data.kubernetes_secret.vault_reviewer_token_data.data["token"]

  depends_on = [vault_auth_backend.kubernetes]
}
