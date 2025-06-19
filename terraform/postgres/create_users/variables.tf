variable "vault_addr" {
  description = "Vault endpoint address"
  type        = string
}

variable "vault_username" {
  description = "Vault username for authentication"
  type        = string
}

variable "vault_password" {
  description = "Vault password for authentication"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database name for the application"
  type        = string
}

variable "db_port" {
  description = "Port for the database"
  type        = string
}


variable "db_root_username" {
  description = "Username for Postgres root user"
  type        = string
}

# variable "postgres_password" {
#   description = "Username for Postgres root user"
#   type        = string
#   sensitive   = true
# }


variable "db_name" {
  description = "Database name for the application"
  type        = string
}
