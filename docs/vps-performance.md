# Desempenho em VPS (Hostinger e similares)

Notas para CS2 / servidores pesados em CPU, alinhadas a **este** projeto (Wings em Docker).

## 1. Steal time (`%st`) — vizinhança no host

Em KVM compartilhado, a CPU pode ser “emprestada” a outros clientes no mesmo nó físico.

- SSH na VPS e corre `htop` (ou `top`).
- No `htop`, a linha **St** (steal time) ou no `top` a coluna **%st** indica esse efeito.
- Valores **consistentemente acima de ~5–10%** sugerem contenção no host: não há ajuste no Wings que compense — é limite do plano/nó.

## 2. Limite de CPU no painel (o que costuma “desbloquear” o arranque)

No **Pterodactyl Panel**, no servidor (Allocation / Resources), o **CPU Limit** em **0** significa **sem quota de CPU** (ilimitado ao nível do Docker/cgroup), o que evita bloqueios quando a soma de limites ou quotas não bate com o que o processo precisa.

Isto não é um campo “overcommit” no `config.yml`; é configuração **por servidor** no painel.

## 3. `config.yml` do Wings (`/etc/pterodactyl/config.yml` no host)

Não existe uma chave documentada chamada “overcommit” no Wings. O que pode interessar em instalações avançadas:

- **`installer_limits`** — limites dos contentores de **instalação** (não do servidor em jogo). Se o instalador ficar apertado, podes subir `cpu` / `memory` aqui. Ver [documentação oficial](https://pterodactyl.io/wings/1.0/configuration.html#installer-limits).

Depois de editar o `config.yml`:

- **Neste repo** (Wings em Docker):  
  `docker compose restart wings`
- **Wings instalado no systemd no host**:  
  `sudo systemctl restart wings`

## 4. Governor `performance` (opcional, requer permissões)

```bash
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

Muitas VPS **não** expõem `cpufreq` ou ignoram o governor — se o ficheiro não existir ou o comando falhar, é normal.

## 5. CS2 (Source 2) e planos pequenos

CS2 depende muito de **desempenho de um núcleo**. Planos de entrada (poucas vCPU fracas + steal alto) tendem a **LONG FRAME** e stutter mesmo com CPU limit a 0; aí a solução prática é **upgrade**, **menos slots/plugins**, ou **menos trabalho por tick** (menos plugins pesados, etc.).
