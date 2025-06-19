terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.20.0" # Or latest stable version
    }
  }
}


# Read the secret from Vault
data "vault_kv_secret_v2" "postgres_root" {
  mount = "secret"
  name  = "database/admin"

}

locals {
  postgres_root_username = data.vault_kv_secret_v2.postgres_root.data["username"]
  postgres_root_password = data.vault_kv_secret_v2.postgres_root.data["password"]
}

// login to postgresql database with super user
provider "postgresql" {
  host     = var.db_host
  port     = var.db_port
  username = local.postgres_root_username
  password = local.postgres_root_password
  sslmode  = "disable"
}


// Grab user from yaml file
locals {
  raw_yaml = yamldecode(file("${path.module}/values.yaml"))

  flat_user_list = flatten([
    for service, config in local.raw_yaml : [
      for user in try(config.database.users, []) : {
        service = service
        user    = user
        key     = "${service}_${user}"
      }
    ]
  ])

  postgres_users = {
    for entry in local.flat_user_list :
    entry.key => entry
  }
}

# Store to Vault with path like authify/database/users/authify_db_user
resource "vault_kv_secret_v2" "user_secrets" {
  for_each = local.postgres_users

  mount = "secret"
  name  = "${each.value.service}/database/users/${each.value.user}"

  # This reference to random_password.user_passwords automatically creates dependency
  data_json = jsonencode({
    username = each.value.user
    password = random_password.user_passwords[each.key].result
  })

  depends_on = [
    data.vault_kv_secret_v2.postgres_root,
  ]
}

// Generate random password
resource "random_password" "user_passwords" {
  for_each = local.postgres_users
  length   = 12
  special  = false
}

# Create the user
resource "postgresql_role" "db_user" {
  for_each = random_password.user_passwords

  name     = local.postgres_users[each.key].user
  login    = true
  password = each.value.result

  depends_on = [
    vault_kv_secret_v2.user_secrets
  ]
}

resource "postgresql_grant" "user_db_connect" {
  for_each    = random_password.user_passwords
  role        = local.postgres_users[each.key].user
  database    = var.db_name
  object_type = "database"
  privileges  = ["CONNECT"]
  depends_on  = [postgresql_role.db_user]
}

resource "postgresql_grant" "user_schema_grants" {
  for_each    = random_password.user_passwords
  role        = local.postgres_users[each.key].user
  database    = var.db_name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [postgresql_role.db_user]
}

resource "postgresql_grant" "user_table_grants" {
  for_each    = random_password.user_passwords
  role        = local.postgres_users[each.key].user
  database    = var.db_name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"]

  depends_on = [postgresql_role.db_user]
}

resource "postgresql_grant" "user_sequence_grants" {
  for_each    = random_password.user_passwords
  role        = local.postgres_users[each.key].user
  database    = var.db_name
  schema      = "public"
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]

  depends_on = [postgresql_role.db_user]
}
