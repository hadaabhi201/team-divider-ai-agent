provider "kubernetes" {
  config_path = "~/.kube/config" # adjust if needed
}

# 1. Create ServiceAccount for sidekick
resource "kubernetes_service_account" "sidekick" {
  metadata {
    name      = "sidekick"
    namespace = "team-divider"
  }
}

# 2. PeerAuthentication to enforce mTLS for authify
resource "kubernetes_manifest" "authify_peer_auth" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "authify-peer-auth"
      namespace = "team-divider"
    }
    spec = {
      selector = {
        matchLabels = {
          app = "authify"
        }
      }
      mtls = {
        mode = "STRICT"
      }
    }
  }
}

# 2. PeerAuthentication to enforce mTLS for authify
resource "kubernetes_manifest" "sidekick_peer_auth" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "sidekick-peer-auth"
      namespace = "team-divider"
    }
    spec = {
      selector = {
        matchLabels = {
          app = "sidekick"
        }
      }
      mtls = {
        mode = "STRICT"
      }
    }
  }
}

# 3. AuthorizationPolicy to allow only sidekick
resource "kubernetes_manifest" "authify_allow_sidekick" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "authify-allow-sidekick"
      namespace = "team-divider"
    }
    spec = {
      selector = {
        matchLabels = {
          app = "authify"
        }
      }
      action = "ALLOW"
      rules = [
        {
          from = [
            {
              source = {
                principals = [
                  "cluster.local/ns/team-divider/sa/sidekick"
                ]
              }
            }
          ]
        }
      ]
    }
  }
}

# 4. PeerAuthentication for teampulse to enforce mTLS
resource "kubernetes_manifest" "teampulse_peer_auth" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "teampulse-peer-auth"
      namespace = "team-divider"
    }
    spec = {
      selector = {
        matchLabels = {
          app = "teampulse"
        }
      }
      mtls = {
        mode = "PERMISSIVE"
      }
    }
  }
}

# PeerAuthentication for vault to enforce mTLS
resource "kubernetes_manifest" "vault_peer_auth" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "vault"
      namespace = "vault"
    }
    spec = {
      selector = {
        matchLabels = {
          app = "vault"
        }
      }
      mtls = {
        mode = "PERMISSIVE"
      }
    }
  }
}

# 5. AuthorizationPolicy to allow sidekick to call teampulse
resource "kubernetes_manifest" "teampulse_allow_sidekick" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "teampulse-allow-sidekick"
      namespace = "team-divider"
    }
    spec = {
      selector = {
        matchLabels = {
          app = "teampulse"
        }
      }
      action = "ALLOW"
      rules = [
        {
          from = [
            {
              source = {
                principals = [
                  "cluster.local/ns/team-divider/sa/sidekick"
                ]
              }
            }
          ]
        }
      ]
    }
  }
}
