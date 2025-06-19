resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.27.0"

  values = [yamlencode({
    server = {
      dataStorage = {
        enabled      = true
        size         = "200Mi"
        storageClass = "standard"
      }
    },
    injector = {
      enabled  = true
      logLevel = "debug"
      tls = {
        enabled        = true
        useCertManager = false # Let Helm generate self-signed certs
      }
    }
  })]
}

locals {
  yaml_files = fileset("${path.module}/resources", "*.yaml")
}

resource "null_resource" "apply_vault_virtualservice" {
  provisioner "local-exec" {
    command     = <<EOT
kubectl apply -f ${path.module}/resources/

Write-Host "Waiting for VirtualService 'vault' to be available..."
for ($i = 0; $i -lt 30; $i++) {
  $vs = kubectl get virtualservice vault -n vault 2>$null
  if ($LASTEXITCODE -eq 0) {
    break
  }
  Start-Sleep -Seconds 2
}

kubectl get virtualservice vault -n vault -o yaml
EOT
    interpreter = ["PowerShell", "-Command"]
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    helm_release.vault,
    kubernetes_namespace.vault
  ]
}


resource "null_resource" "init_vault" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/vault_initialize.sh"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    helm_release.vault,
    null_resource.apply_vault_virtualservice
  ]
}

resource "null_resource" "create_user" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/create_users.sh"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    helm_release.vault,
    null_resource.apply_vault_virtualservice,
    null_resource.init_vault
  ]
}

module "authify_jwt_secret" {
  source = "./resources"
}
