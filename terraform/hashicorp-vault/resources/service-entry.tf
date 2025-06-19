# apiVersion: networking.istio.io/v1beta1
# kind: ServiceEntry
# metadata:
#   name: allow-vault
#   namespace: team-divider
# spec:
#   hosts:
#     - "vault.vault.svc.cluster.local"
#   location: MESH_INTERNAL
#   ports:
#     - number: 8200
#       name: http
#       protocol: HTTP
#   resolution: DNS
