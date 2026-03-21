#!/bin/sh
set -e
# CADDYFILE_URL=https://... para Caddyfile remoto; vazio = /caddy-data/Caddyfile (bind ./caddy no compose).
CONFIG="${CADDYFILE_URL:-/caddy-data/Caddyfile}"
exec caddy run --config "$CONFIG" --adapter caddyfile
