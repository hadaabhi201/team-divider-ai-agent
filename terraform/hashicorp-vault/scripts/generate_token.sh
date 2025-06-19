#!/usr/bin/env bash
set -euo pipefail

SERVICE_ACCOUNT="vault"
NAMESPACE="vault"
TOKEN_FILE="./tmp/k8s_sa_token.jwt"
CA_FILE="./tmp/k8s_ca_cert.pem"

JWT=$(kubectl create token "$SERVICE_ACCOUNT" -n "$NAMESPACE")
CA_CRT=$(kubectl get secret "$(kubectl get sa "$SERVICE_ACCOUNT" -n "$NAMESPACE" -o jsonpath="{.secrets[0].name}")" -n "$NAMESPACE" -o jsonpath="{.data['ca\.crt']}" | base64 -d)

mkdir -p ./tmp
echo "$JWT" > "$TOKEN_FILE"
echo "$CA_CRT" > "$CA_FILE"

echo "✅ Wrote token to $TOKEN_FILE"
echo "✅ Wrote CA cert to $CA_FILE"
