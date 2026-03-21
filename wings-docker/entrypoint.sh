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

# Muda a subnet do pterodactyl0 para evitar conflito com redes Docker existentes.
fix_docker_subnet() {
  [[ -f /etc/pterodactyl/config.yml ]] || return 0
  local subnet="${WINGS_DOCKER_SUBNET:-172.20.0.0/16}"
  local gateway="${WINGS_DOCKER_GATEWAY:-172.20.0.1}"
  yq -i "
    .docker.network.interface = \"${gateway}\" |
    .docker.network.interfaces.v4.subnet = \"${subnet}\" |
    .docker.network.interfaces.v4.gateway = \"${gateway}\"
  " /etc/pterodactyl/config.yml
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
  fix_docker_subnet
else
  fix_behind_caddy
  fix_docker_subnet
fi

exec wings
