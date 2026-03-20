#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v docker &>/dev/null; then
  echo "Erro: docker não encontrado."
  exit 1
fi

if grep -q 'ptla_SUBSTITUIR_PELA_APPLICATION_API_KEY' docker-compose.yml 2>/dev/null; then
  echo "Edita docker-compose.yml: define WINGS_APP_API_TOKEN em x-wings-env (e o resto conforme precisares)."
  exit 1
fi

echo "A parar wings no systemd (se existir), para não haver conflito na 8080 ..."
systemctl disable --now wings 2>/dev/null || true

echo "A criar diretórios no host ..."
mkdir -p /etc/pterodactyl /var/lib/pterodactyl/volumes /var/lib/pterodactyl/containers \
  /var/log/pterodactyl /run/wings

echo "A construir e subir stack ..."
docker compose build wings
docker compose up -d

fqdn=$(awk -F'"' '/WINGS_FQDN:/{print $2; exit}' docker-compose.yml || true)
echo ""
echo "Logs Wings:  docker compose logs -f wings"
echo "Logs Caddy: docker compose logs -f caddy"
[[ -n "${fqdn:-}" ]] && echo "Teste:       curl -sI https://${fqdn}/"
echo "Painel:     FQDN = WINGS_FQDN do compose; SSL ligado; porta 443"
