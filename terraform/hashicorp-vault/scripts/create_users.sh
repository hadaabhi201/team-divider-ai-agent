#!/usr/bin/env bash
set -euo pipefail

VAULT_ADDR="http://team-divider.vault"
VAULT_INIT_FILE="vault-init.json"
VAULT_ROOT_TOKEN=$(jq -r .root_token "$VAULT_INIT_FILE")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/vault_user_config.sh"


echo "🔐 root token = $VAULT_ROOT_TOKEN"

# Wait until Vault is unsealed and active
echo "📡 Checking Vault health at: $VAULT_ADDR/v1/sys/health"

until curl --silent --fail "$VAULT_ADDR/v1/sys/health" | tee /tmp/vault_health_response.json | grep -q '"sealed":false'; do
  echo "⏳ Waiting for Vault to be unsealed and active..."
  echo "📋 Vault response: $(cat /tmp/vault_health_response.json)"
  sleep 2
done
echo "✅ Vault is unsealed."

echo "🔐 Enabling userpass auth method (if needed)..."
curl \
  --header "X-Vault-Token: $VAULT_ROOT_TOKEN" \
  --request POST \
  --data '{"type": "userpass"}' \
  "$VAULT_ADDR/v1/sys/auth/userpass" || echo "Auth method may already be enabled."
  
export VAULT_ADDR="$VAULT_ADDR"
# Create the policy
echo "📜 Writing '$VAULT_POLICY' policy..."
vault policy write "$VAULT_POLICY" "$SCRIPT_DIR/${VAULT_POLICY}-policy.hcl"

# Create a user
echo "👤 Creating user '$VAULT_USERNAME'..."
vault write auth/userpass/users/"$VAULT_USERNAME" password="$VAULT_PASSWORD" policies="$VAULT_POLICY"
