
variable "name" {}
variable "namespace" {}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = "${var.name}-vault-sa"
    namespace = var.namespace
  }
}

output "name" {
  value = kubernetes_service_account.this.metadata[0].name
}

output "namespace" {
  value = kubernetes_service_account.this.metadata[0].namespace
}
