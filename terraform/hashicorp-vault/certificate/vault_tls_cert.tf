provider "vault" {
  address = "http://team-divider.vault"
  token   = jsondecode(file("${path.module}/../vault-init.json")).root_token
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "PKI backend"
}

resource "vault_pki_secret_backend_config_urls" "pki_urls" {
  backend = vault_mount.pki.path

  issuing_certificates    = ["http://vault.vault.svc:8200/v1/pki/ca"]
  crl_distribution_points = ["http://vault.vault.svc:8200/v1/pki/crl"]
}

resource "vault_pki_secret_backend_root_cert" "root_cert" {
  backend     = vault_mount.pki.path
  type        = "internal" # ✅ Fix: Required field
  common_name = "team-divider.local"
  ttl         = "87600h"
  format      = "pem"
  key_type    = "rsa"
  key_bits    = 2048
}


resource "vault_pki_secret_backend_role" "istio_role" {
  backend            = vault_mount.pki.path
  name               = "istio-cert-role"
  allowed_domains    = ["team-divider.local"]
  allow_subdomains   = true
  allow_bare_domains = true
  max_ttl            = "720h"
  generate_lease     = true
}

# ✅ Issue cert using a resource instead of data block
resource "vault_pki_secret_backend_cert" "istio_cert" {
  backend     = vault_mount.pki.path
  name        = vault_pki_secret_backend_role.istio_role.name
  common_name = "team-divider.local"
  ttl         = "360h"
}

# Create Kubernetes TLS secret for Istio
resource "kubernetes_secret" "istio_tls" {
  metadata {
    name      = "istio-ingressgateway-certs"
    namespace = "istio-system"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = vault_pki_secret_backend_cert.istio_cert.certificate # No base64encode
    "tls.key" = vault_pki_secret_backend_cert.istio_cert.private_key # No base64encode
  }
}
