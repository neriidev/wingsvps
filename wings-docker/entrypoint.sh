#!/usr/bin/env bash
set -euo pipefail

mkdir -p /var/lib/pterodactyl/volumes /var/lib/pterodactyl/containers \
  /var/log/pterodactyl /run/wings

panel_url="${WINGS_PANEL_URL:-}"
panel_url="${panel_url%/}"

fix_behind_caddy() {
  [[ "${WINGS_BEHIND_CADDY:-1}" != "1" ]] && return 0
  [[ -f /etc/pterodactyl/config.yml ]] || return 0
  yq -i '.api.port = 8080 | .api.ssl.enabled = false' /etc/pterodactyl/config.yml
}

if [[ ! -s /etc/pterodactyl/config.yml ]] || [[ "${WINGS_FORCE_CONFIGURE:-0}" == "1" ]]; then
  : "${WINGS_PANEL_URL:?defina WINGS_PANEL_URL no .env}"
  : "${WINGS_APP_API_TOKEN:?defina WINGS_APP_API_TOKEN (ptla_...) no .env}"
  : "${WINGS_NODE_ID:?defina WINGS_NODE_ID no .env}"
  wings configure \
    --panel-url "$panel_url" \
    --token "$WINGS_APP_API_TOKEN" \
    --node "$WINGS_NODE_ID" \
    --override
  fix_behind_caddy
else
  fix_behind_caddy
fi

exec wings
