#!/bin/sh
set -e
# CADDYFILE_URL=https://... para Caddyfile remoto; vazio = /etc/caddy/Caddyfile (bind mount local).
CONFIG="${CADDYFILE_URL:-/etc/caddy/Caddyfile}"
exec caddy run --config "$CONFIG" --adapter caddyfile
