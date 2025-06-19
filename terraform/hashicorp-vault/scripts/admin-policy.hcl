# Base full access
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Explicit access to identity APIs (UI needs these)
path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Listing entity IDs (UI and CLI)
path "identity/entity/id" {
  capabilities = ["list"]
}

# Access to auth methods metadata
path "auth/*" {
  capabilities = ["read", "list"]
}

# Optional: access to UI backend paths
path "sys/internal/ui/*" {
  capabilities = ["read", "list"]
}
