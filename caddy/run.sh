#!/bin/sh
set -e
# CADDYFILE_URL=https://... para Caddyfile remoto; vazio = cópia local em /caddy/Caddyfile (pasta montada).
CONFIG="${CADDYFILE_URL:-/caddy/Caddyfile}"
exec caddy run --config "$CONFIG" --adapter caddyfile
