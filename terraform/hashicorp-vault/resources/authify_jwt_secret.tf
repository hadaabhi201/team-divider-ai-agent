resource "random_password" "authify_jwt_secret" {
  length  = 16
  special = false
}

resource "null_resource" "load_token" {
  provisioner "local-exec" {
    command = "bash ${path.module}/../scripts/load_token.sh"
  }

  triggers = {
    always_run = timestamp()
  }
}

provider "vault" {
}
resource "vault_kv_secret_v2" "authify_jwt_secret" {
  mount = "secret"
  name  = "authify/jwt"

  data_json = jsonencode({
    JWT_SECRET = random_password.authify_jwt_secret.result
  })

  depends_on = [random_password.authify_jwt_secret, null_resource.load_token]
}
