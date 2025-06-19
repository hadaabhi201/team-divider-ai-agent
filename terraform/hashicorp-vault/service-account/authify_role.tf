
module "authify_sa" {
  source    = "./modules/vault_service_account"
  name      = "authify"
  namespace = "team-divider"
}

resource "vault_policy" "authify" {
  name   = "authify-policy"
  policy = file("${path.module}/policies/authify-policy.hcl")
}

resource "vault_kubernetes_auth_backend_role" "authify_role" {
  role_name                        = "authify-vault-role"
  backend                          = vault_kubernetes_auth_backend_config.k8s.backend
  bound_service_account_names      = [module.authify_sa.name]
  bound_service_account_namespaces = [module.authify_sa.namespace]
  token_policies                   = [vault_policy.authify.name]
  token_ttl                        = 86400

  depends_on = [
    vault_policy.authify,
    vault_kubernetes_auth_backend_config.k8s
  ]
}
