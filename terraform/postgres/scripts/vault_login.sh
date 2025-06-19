#!/bin/bash
set -e

VAULT_ADDR="$1"
VAULT_USERNAME="$2"
VAULT_PASSWORD="$3"

export VAULT_ADDR
export VAULT_SKIP_VERIFY=true

echo "📡 VAULT_ADDR: $VAULT_ADDR"
echo "🔑 VAULT_TOKEN: $VAULT_TOKEN"

echo "🔐 Logging in to Vault with userpass..."

TOKEN=$(vault login -method=userpass \
  username="$VAULT_USERNAME" \
  password="$VAULT_PASSWORD" \
  -format=json | jq -r '.auth.client_token')

if [[ -z "$TOKEN" ]]; then
  echo "❌ Failed to retrieve Vault token"
  exit 1
fi

echo "✅ VAULT_TOKEN=$TOKEN"

export VAULT_TOKEN="$TOKEN"
