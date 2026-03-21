# VPS — Wings + Caddy só com Docker

Sobe **Wings** e **Caddy** (Let’s Encrypt) com **`docker compose`** (plugin **v2** do Docker). **Não** uses o pacote antigo **`docker-compose`** do `apt` (Compose v1) — dá erros tipo `KeyError: 'id'`. As variáveis ficam no próprio **`docker-compose.yml`** (blocos `x-wings-env`, `x-caddy-env` e `x-mysql-env`). Na primeira subida o Wings corre **`wings configure`** sozinho — não precisas de `.env` nem systemd no host.

## Como funciona

- **Wings** em `wings-docker/` com **`network_mode: host`** e **`docker.sock`** — game servers como contentores no host.
- **Bind mounts** em `/etc/pterodactyl` e `/var/lib/pterodactyl` no host.
- **Caddy** termina TLS na **443** e faz proxy para **127.0.0.1:8080**. Com `WINGS_BEHIND_CADDY: "1"`, o entrypoint força **8080** e **ssl: false** no `config.yml`.
- **MySQL** (opcional) na porta **3306** do host, com volume **`mysql_data`**. Os **plugins** dos servidores (contentores Docker) ligam ao **IP do host** na **3306**, não ao nome `mysql` (o Wings usa `network_mode: host`; os game servers não estão na mesma rede Docker que o MySQL).

## Configurar

1. Abre **`docker-compose.yml`** e edita no topo:
   - **`x-wings-env`**: `WINGS_PANEL_URL`, `WINGS_APP_API_TOKEN` (`ptla_...`), `WINGS_NODE_ID`, `WINGS_FORCE_CONFIGURE`, `WINGS_BEHIND_CADDY`
   - **`x-caddy-env`**: `WINGS_FQDN` (DNS A → IP desta VPS); opcionalmente **`CADDYFILE_URL`** (ver abaixo)
   - **`x-mysql-env`**: `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` (se usares o serviço `mysql`)
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
| `WINGS_FQDN` | Subdomínio público (ex.: `srv1.vulkan.ninja`) |
| `WINGS_BEHIND_CADDY` | `"1"` recomendado (HTTP 8080 atrás do Caddy) |
| `WINGS_FORCE_CONFIGURE` | `"1"` para voltar a correr `wings configure` no arranque |

### MySQL nos plugins (servidores)

No **ficheiro de config do plugin** (ex. LuckyPerms), usa:

| Campo | Valor típico |
|--------|----------------|
| Host | IP **público/privado** desta VPS (o mesmo que o painel usa para o node), **ou** em muitos nós Linux o gateway Docker **`172.17.0.1`** |
| Porta | `3306` |
| Base de dados / utilizador / senha | Iguais a `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` no `x-mysql-env` |

Protege a **3306** com firewall (só IPs que precisam) se a máquina for exposta à Internet.

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
docker compose logs -f mysql
```

Para subir só o MySQL (útil para testar): `docker compose up -d mysql`

## Caddyfile remoto

O Docker **não** faz bind mount de URLs. O Caddy suporta carregar um Caddyfile por **HTTPS**: define no **`x-caddy-env`**:

```yaml
CADDYFILE_URL: "https://raw.githubusercontent.com/USUARIO/REPO/main/caddy/Caddyfile"
```

Exemplos de origem: **raw** do GitHub/GitLab, bucket com URL pública, etc. Mantém **`WINGS_FQDN`** (e outras `{$VAR}`) no ficheiro remoto — o Caddy substitui com as variáveis de ambiente do serviço `caddy` no compose.

- Com **`CADDYFILE_URL` vazio** (`""`), usa o ficheiro local **`caddy/Caddyfile`** (a pasta **`caddy/`** monta em **`/caddy-data`** no contentor).
- O arranque usa **`caddy/Dockerfile`**: o **`run.sh`** fica **dentro da imagem**, por isso não depende do bind mount (útil na Hostinger quando o clone não expõe bem a pasta). Com **URL definida**, o mount **`./caddy`** só é necessário se quiseres cópia local em paralelo; podes comentá-lo se usares só remoto.

### Deploy (Hostinger / clone só do compose)

Se aparecer *mount … not a directory* em `Caddyfile`: no primeiro arranque o Docker pode ter criado um **diretório** com esse nome no host. No servidor, remove e volta a fazer deploy após ter o repositório completo com **`caddy/`** (inclui **`Dockerfile`**, **`run.sh`** e **`Caddyfile`**):

```bash
rm -rf /docker/wingsvps2/Caddyfile
```

(Ajusta o caminho ao que o painel mostrar no erro.)
- Usa **HTTPS** e uma fonte em que confies: quem controla essa URL controla a config do reverse proxy.

## Cloudflare

Registo **A** pode precisar de **DNS only** até o certificado Let's Encrypt emitir.

## Desempenho (VPS / CS2 / steal time)

Notas sobre **steal time**, limites de CPU no painel e reinício do Wings com Docker: ver [`docs/vps-performance.md`](docs/vps-performance.md).
