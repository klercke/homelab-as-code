#!/usr/bin/env bash
set -euo pipefail

usage="usage: build-installer-iso.sh [--burn] HOST SOURCE_ISO"

burn=0
args=()
for arg in "$@"; do
  case "$arg" in
    --burn) burn=1 ;;
    -h|--help) echo "$usage"; exit 0 ;;
    -*) echo "unknown option: $arg" >&2; echo "$usage" >&2; exit 2 ;;
    *) args+=("$arg") ;;
  esac
done
[ "${#args[@]}" -eq 2 ] || { echo "$usage" >&2; exit 2; }
host="${args[0]}"
src_iso="${args[1]}"

repo="$(git rev-parse --show-toplevel)"
sops_file="${SOPS_FILE:-$repo/secrets/infra.sops.yaml}"
tmpl="$repo/installer/$host.toml.tmpl"
out="$repo/installer/build"

[ -f "$tmpl" ] || { echo "no answer template: $tmpl" >&2; exit 1; }

umask 077
mkdir -p "$out"

ROOT_PASSWORD_HASH="$(sops -d --extract '["installer"]["root_password_hash"]' "$sops_file")"
ROOT_MAILTO="$(sops -d --extract '["installer"]["root_mailto"]' "$sops_file")"
export ROOT_PASSWORD_HASH ROOT_MAILTO

envsubst '${ROOT_PASSWORD_HASH} ${ROOT_MAILTO}' < "$tmpl" > "$out/$host.toml"

proxmox-auto-install-assistant validate-answer "$out/$host.toml"
proxmox-auto-install-assistant prepare-iso "$src_iso" \
  --fetch-from iso \
  --answer-file "$out/$host.toml" \
  --output "$out/$host.iso"

sha256sum "$out/$host.iso" | tee "$out/$host.iso.sha256"

if [ "$burn" -eq 1 ]; then
  sri="sha256-$(openssl dgst -sha256 -binary "$out/$host.iso" | base64)"
  caligula burn "$out/$host.iso" --compression none --hash "$sri"
fi
