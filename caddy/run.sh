#!/bin/sh
set -e
# CADDYFILE_URL=https://... para Caddyfile remoto; vazio = /caddy-data/Caddyfile (bind ./caddy no compose).
# O Caddy não faz fetch de URL no --config; usamos curl para descarregar.
SRC="${CADDYFILE_URL:-}"
if [ -n "$SRC" ] && [ "${SRC#http://}" != "$SRC" ] || [ "${SRC#https://}" != "$SRC" ]; then
  CONFIG=$(mktemp)
  trap 'rm -f "$CONFIG"' EXIT
  curl -fsSL -o "$CONFIG" "$SRC"
else
  CONFIG="${SRC:-/caddy-data/Caddyfile}"
fi
exec caddy run --config "$CONFIG" --adapter caddyfile
