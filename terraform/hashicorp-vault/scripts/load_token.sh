#!/usr/bin/env bash
set -euo pipefail

VAULT_ADDR="http://team-divider.vault"
export VAULT_ADDR

VAULT_INIT_FILE="./vault-init.json"
TOKEN_FILE="./tmp/vault_root_token.txt"

if [[ ! -f "$VAULT_INIT_FILE" ]]; then
  echo "❌ $VAULT_INIT_FILE not found."
  exit 1
fi

VAULT_TOKEN=$(jq -r .root_token "$VAULT_INIT_FILE")
export VAULT_TOKEN

mkdir -p ./tmp
echo "$VAULT_TOKEN" > "$TOKEN_FILE"
echo "🔐 Token written to $TOKEN_FILE"
