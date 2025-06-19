provider "vault" {
  address = var.vault_addr
}

resource "vault_mount" "secret_kv_v2" {
  path        = "secret"
  type        = "kv"
  description = "Key-Value V2 secret engine"
  options = {
    version = "2"
  }
}

variable "password_version" {
  description = "Increment to regenerate the password"
  type        = number
  default     = 2
}

resource "random_password" "postgres_root" {
  length  = 12
  special = false

  keepers = {
    version = var.password_version
  }
}

resource "vault_kv_secret_v2" "postgres_root_secret" {
  mount = "secret" # use string instead of vault_mount.secret.path
  name  = "database/admin"

  data_json = jsonencode({
    username = var.db_root_username
    password = random_password.postgres_root.result
  })

  depends_on = [vault_mount.secret_kv_v2]
}
