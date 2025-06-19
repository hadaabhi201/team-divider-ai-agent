module "teampulse_sa" {
  source    = "./modules/vault_service_account"
  name      = "teampulse"
  namespace = "team-divider"
}

resource "vault_policy" "teampulse" {
  name   = "teampulse-policy"
  policy = file("${path.module}/policies/teampulse-policy.hcl")
}

resource "vault_kubernetes_auth_backend_role" "teampulse_role" {
  role_name                        = "teampulse-vault-role"
  backend                          = vault_kubernetes_auth_backend_config.k8s.backend
  bound_service_account_names      = [module.teampulse_sa.name]
  bound_service_account_namespaces = [module.teampulse_sa.namespace]
  token_policies                   = [vault_policy.teampulse.name]
  token_ttl                        = 86400

  depends_on = [
    vault_policy.teampulse,
    vault_kubernetes_auth_backend_config.k8s
  ]
}
