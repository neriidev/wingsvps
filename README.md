# VPS — Wings + Caddy só com Docker

Sobe **Wings** e **Caddy** (Let’s Encrypt) com **`docker compose`** (plugin **v2** do Docker). **Não** uses o pacote antigo **`docker-compose`** do `apt` (Compose v1) — dá erros tipo `KeyError: 'id'`. As variáveis ficam no próprio **`docker-compose.yml`** (blocos `x-wings-env` e `x-caddy-env`). Na primeira subida o Wings corre **`wings configure`** sozinho — não precisas de `.env` nem systemd no host.

## Como funciona

- **Wings** em `wings-docker/` com **`network_mode: host`** e **`docker.sock`** — game servers como contentores no host.
- **Bind mounts** em `/etc/pterodactyl` e `/var/lib/pterodactyl` no host.
- **Caddy** termina TLS na **443** e faz proxy para **127.0.0.1:8080**. Com `WINGS_BEHIND_CADDY: "1"`, o entrypoint força **8080** e **ssl: false** no `config.yml`.

## Configurar

1. Abre **`docker-compose.yml`** e edita no topo:
   - **`x-wings-env`**: `WINGS_PANEL_URL`, `WINGS_APP_API_TOKEN` (`ptla_...`), `WINGS_NODE_ID`, `WINGS_FORCE_CONFIGURE`, `WINGS_BEHIND_CADDY`
   - **`x-caddy-env`**: `WINGS_FQDN` (DNS A → IP desta VPS)
2. URL do painel **sem** barra no fim (ou o entrypoint remove).
3. **Não** commits com **Application API key** real em repos públicos.

## Uso

```bash
cd vps
nano docker-compose.yml
chmod +x scripts/bootstrap.sh
sudo ./scripts/bootstrap.sh
```

### Sem o script

```bash
sudo mkdir -p /etc/pterodactyl /var/lib/pterodactyl/volumes /var/lib/pterodactyl/containers /var/log/pterodactyl /run/wings
sudo systemctl disable --now wings 2>/dev/null || true
docker compose build wings && docker compose up -d
```

## Variáveis (no compose)

| Variável | Descrição |
|----------|-----------|
| `WINGS_PANEL_URL` | `https://painel.tld` |
| `WINGS_APP_API_TOKEN` | Chave **Application API** (`ptla_...`) |
| `WINGS_NODE_ID` | ID numérico do node |
| `WINGS_FQDN` | Subdomínio público (ex.: `srv.vulkan.ninja`) |
| `WINGS_BEHIND_CADDY` | `"1"` recomendado (HTTP 8080 atrás do Caddy) |
| `WINGS_FORCE_CONFIGURE` | `"1"` para voltar a correr `wings configure` no arranque |

## Painel (node)

| Campo | Valor |
|--------|--------|
| FQDN | Igual a `WINGS_FQDN` |
| Communicate Over SSL | **Sim** |
| Daemon Port | **443** |

## Comandos úteis

```bash
docker compose logs -f wings
docker compose restart wings
docker compose down
```

## Cloudflare

Registo **A** pode precisar de **DNS only** até o certificado Let's Encrypt emitir.
