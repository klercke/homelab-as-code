#!/usr/bin/env bash
set -euo pipefail
umask 077
cd "$(git rev-parse --show-toplevel)"

out=secrets/platform.sops.yaml
tmp="$(mktemp -p "${XDG_RUNTIME_DIR:-/run/user/$UID}")"
trap 'rm -f "$tmp"' EXIT

gen() { openssl rand -hex "${1:-24}"; }

cat > "$tmp" <<EOF
postgres_superuser_password: '$(gen)'
postgres_netbox_password: '$(gen)'
postgres_pdns_password: '$(gen)'
postgres_kea_password: '$(gen)'
netbox_secret_key: '$(gen 50)'
netbox_api_token: '$(openssl rand -hex 20)'
pdns_api_key: '$(gen)'
kea_ca_password: '$(gen)'
EOF

expected=8
got=$(grep -cE "^[a-z_]+: '[0-9a-f]+'$" "$tmp")
[ "$got" -eq "$expected" ] || { echo "bad secrets file: $got/$expected lines valid" >&2; exit 1; }
sops -e --filename-override "$out" "$tmp" > "$out"
