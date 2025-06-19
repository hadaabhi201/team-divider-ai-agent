#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
VAULT_INIT_FILE="$SCRIPT_DIR/vault-init.json"

export VAULT_ADDR=http://team-divider.vault
export VAULT_SKIP_VERIFY=true

echo "🔍 Checking Vault status..."
INIT_STATUS=$(vault status -format=json 2>/dev/null || true)
IS_INITIALIZED=$(echo "$INIT_STATUS" | jq -r '.initialized')

echo "IS_INITIALIZED == $IS_INITIALIZED" 
if [[ "$IS_INITIALIZED" == "true" ]]; then
  echo "✅ Vault is already initialized."
else
  echo "🚀 Initializing Vault..."
  vault operator init -key-shares=5 -key-threshold=3 -format=json > "$VAULT_INIT_FILE"
  echo "✅ Vault initialized. Stored in vault-init.json"
fi

SEALED=$(vault status -format=json | jq -r '.sealed')
if [[ "$SEALED" == "true" ]]; then
  echo "🔐 Vault is sealed. Starting unseal process..."
  for i in 0 1 2; do
    echo "🔑 Unsealing with key $i..."
    KEY=$(jq -r ".unseal_keys_b64[$i]" "$VAULT_INIT_FILE")

    if [[ -z "$KEY" || "$KEY" == "null" ]]; then
      echo "❌ Invalid unseal key at index $i"
      exit 1
    fi

    vault operator unseal "$KEY"
  done

  # Wait for Vault to be fully unsealed
  echo "⏳ Verifying unseal status..."
  for i in {1..10}; do
    SEALED=$(vault status -format=json | jq -r '.sealed')
    if [[ "$SEALED" == "false" ]]; then
      echo "✅ Vault is unsealed."
      break
    fi
    echo "🔒 Vault still sealed. Retrying in 5s..."
    sleep 5
  done

  SEALED=$(vault status -format=json | jq -r '.sealed')
  if [[ "$SEALED" == "true" ]]; then
    echo "❌ Vault is still sealed after retries. Exiting."
    exit 1
  fi
else
  echo "✅ Vault is already unsealed. Skipping unseal."
fi

# Optional: Login with root token
ROOT_TOKEN=$(jq -r '.root_token' "$VAULT_INIT_FILE")
vault login "$ROOT_TOKEN"
