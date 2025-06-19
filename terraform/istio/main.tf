terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.21.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

resource "kubernetes_namespace" "team_divider" {
  metadata {
    name = var.app_namespace
    labels = {
      istio-injection                       = "enabled"
      "vault.hashicorp.com/agent-injection" = "enabled"
    }
  }
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  namespace        = var.istio_namespace
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  create_namespace = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = var.istio_namespace
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  depends_on = [helm_release.istio_base]

  values = [yamlencode({
    meshConfig = {
      defaultConfig = {
        proxyMetadata = {
          ISTIO_META_CERT_TTL = "168h" # 7 days
        }
      }
    },
    pilot = {
      env = {
        PILOT_CERT_TTL               = "168h" # Issued cert validity
        PILOT_CERT_ROTATION_INTERVAL = "72h"  # How often to rotate
      }
    }
  })]
}

resource "helm_release" "istio_gateway" {
  name       = "istio-ingress"
  namespace  = var.istio_namespace
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"

  values = [yamlencode({
    service = {
      type = "LoadBalancer"
    },
    labels = {
      istio = "ingress" # Matches Gateway selector
    }
  })]

  depends_on = [helm_release.istiod]
}
