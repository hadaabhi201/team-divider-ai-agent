locals {
  # Just pass the list of files and apply with kubectl directly
  yaml_files = fileset("${path.module}/resources", "*.yaml")
}

resource "null_resource" "apply_istio_gateway" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/resources/"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod,
    helm_release.istio_gateway,
    kubernetes_namespace.team_divider
  ]
}
