LXC 104 menjalankan Authentik sebagai identity provider dan SSO/OIDC provider untuk seluruh service homelab.

> **Pastikan LXC 103 (database) sudah running** sebelum deploy LXC ini — Authentik memerlukan PostgreSQL dan Redis.

## Specs

| | |
|---|---|
| CT ID | 104 |
| Hostname | auth |
| OS | Ubuntu 24.04 LTS |
| CPU | 2 cores |
| RAM | 2048MB |
| Swap | 1024MB |
| Disk | 16GB (local-lvm) |
| Unprivileged | Yes |
| Nesting | Yes (Docker) |

## Network

| | |
|---|---|
| IP | 192.168.100.104/24 |
| Gateway | 192.168.100.1 |
| DNS | 192.168.100.101 |
| Search domain | homelab.local |

## Dependencies

| Service | Host | Catatan |
|---|---|---|
| PostgreSQL | 192.168.100.103:5432 | db_authentik / authentik_user |
| Redis | 192.168.100.103:6379 | db index 2 |

> Untuk langkah pembuatan LXC step by step, lihat [create-lxc-guide.md](../runbooks/create-lxc-guide.md).

---

## Services

### Authentik

| | |
|---|---|
| URL | https://auth.homelab.local |
| Admin UI | https://auth.homelab.local/if/admin/ |
| Initial setup | http://192.168.100.104:9000/if/flow/initial-setup/ |
| Path | /opt/stacks/authentik/ |

#### Generate Secret Key

```bash
openssl rand -hex 32
```

Simpan ke Vaultwarden sebelum melanjutkan.

#### .env

```bash
nano /opt/stacks/authentik/.env
```

```env
AUTHENTIK_POSTGRESQL__PASSWORD=authentik_db_password
AUTHENTIK_REDIS__PASSWORD=redis_password
AUTHENTIK_SECRET_KEY=your_secret_key
AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS=192.168.100.0/24
```

> `AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS` wajib dikonfigurasi agar Authentik mempercayai X-Forwarded headers dari NPM. Tanpa ini, UI Authentik akan ter-render sebagai plain text saat diakses via domain.

#### docker-compose.yml

```yaml
services:
  authentik-server:
    image: ghcr.io/goauthentik/server:latest
    container_name: authentik-server
    command: server
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9443:9443"
    environment:
      AUTHENTIK_REDIS__HOST: "192.168.100.103"
      AUTHENTIK_REDIS__PORT: "6379"
      AUTHENTIK_REDIS__PASSWORD: ${AUTHENTIK_REDIS__PASSWORD}
      AUTHENTIK_REDIS__DB: "2"
      AUTHENTIK_POSTGRESQL__HOST: "192.168.100.103"
      AUTHENTIK_POSTGRESQL__USER: "authentik_user"
      AUTHENTIK_POSTGRESQL__NAME: "db_authentik"
      AUTHENTIK_POSTGRESQL__PASSWORD: ${AUTHENTIK_POSTGRESQL__PASSWORD}
      AUTHENTIK_SECRET_KEY: ${AUTHENTIK_SECRET_KEY}
      AUTHENTIK_ERROR_REPORTING__ENABLED: "false"
      AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS: ${AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS}
    volumes:
      - ./media:/media
      - ./custom-templates:/templates

  authentik-worker:
    image: ghcr.io/goauthentik/server:latest
    container_name: authentik-worker
    command: worker
    restart: unless-stopped
    environment:
      AUTHENTIK_REDIS__HOST: "192.168.100.103"
      AUTHENTIK_REDIS__PORT: "6379"
      AUTHENTIK_REDIS__PASSWORD: ${AUTHENTIK_REDIS__PASSWORD}
      AUTHENTIK_REDIS__DB: "2"
      AUTHENTIK_POSTGRESQL__HOST: "192.168.100.103"
      AUTHENTIK_POSTGRESQL__USER: "authentik_user"
      AUTHENTIK_POSTGRESQL__NAME: "db_authentik"
      AUTHENTIK_POSTGRESQL__PASSWORD: ${AUTHENTIK_POSTGRESQL__PASSWORD}
      AUTHENTIK_SECRET_KEY: ${AUTHENTIK_SECRET_KEY}
      AUTHENTIK_ERROR_REPORTING__ENABLED: "false"
      AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS: ${AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS}
    volumes:
      - ./media:/media
      - ./custom-templates:/templates
      - ./certs:/certs

volumes: {}
```

#### Fix Permission Media Folder

```bash
mkdir -p /opt/stacks/authentik/media /opt/stacks/authentik/custom-templates /opt/stacks/authentik/certs
chown -R 1000:1000 /opt/stacks/authentik/media /opt/stacks/authentik/custom-templates /opt/stacks/authentik/certs
```

> Wajib dijalankan sebelum `docker compose up`. Tanpa ini Authentik akan crash dengan error `PermissionError: /media/public`.

#### Deploy

```bash
cd /opt/stacks/authentik
docker compose up -d
docker compose logs -f authentik-server
```

Tunggu hingga log tidak menampilkan error sebelum membuka browser.

#### Initial Setup

Buka `http://192.168.100.104:9000/if/flow/initial-setup/` → buat admin account.

---

## Setup NPM Proxy Host

| Field | Value |
|---|---|
| Domain | auth.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.104 |
| Forward Port | 9000 |
| Websockets | ✅ |
| SSL | homelab-local |
| Force SSL | ✅ |

**Custom Nginx Configuration** (tab Advanced):
```nginx
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Host $host;
```

> Header ini wajib dikonfigurasi agar Authentik tidak me-render HTML sebagai plain text saat diakses via domain.

> ⚠️ Jangan menambahkan `AUTHENTIK_HOST` atau `AUTHENTIK_HOST_BROWSER` ke environment — akan menyebabkan login loop.

---

## Setup Brands

**System** → **Brands** → Edit `authentik-default` → set **Domain** ke `auth.homelab.local` → Update.

---

## Setup OIDC Provider

### Outline

1. Login ke Admin UI: `https://auth.homelab.local/if/admin/`
2. **Applications** → **Providers** → **Create** → **OAuth2/OpenID Provider**
3. Isi:
   - Name: `outline-provider`
   - Authorization flow: `default-provider-authorization-explicit-consent`
   - Client type: `Confidential`
   - Redirect URIs: `https://outline.homelab.local/auth/oidc.callback`
4. Catat **Client ID** dan **Client Secret** → simpan di Vaultwarden
5. **Applications** → **Applications** → **Create**:
   - Name: `Outline`
   - Slug: `outline`
   - Provider: `outline-provider`

> **OIDC Auth URI yang benar:** `https://auth.homelab.local/application/o/authorize/`
> Verifikasi via: `https://auth.homelab.local/application/o/outline/` → lihat field `authorization_endpoint`

### Postiz

- [ ] Belum dikonfigurasi — setup saat deploy LXC 105

---

## Post-Deploy Checklist

- [x] Authentik accessible di `https://auth.homelab.local`
- [x] Admin account dibuat via initial-setup flow
- [x] Brands domain diset ke `auth.homelab.local`
- [x] NPM proxy host dengan Custom Nginx Config dikonfigurasi
- [x] OIDC provider untuk Outline dibuat
- [x] Client ID dan Client Secret disimpan di Vaultwarden
- [ ] Setup OIDC provider untuk Postiz
- [ ] Setup 2FA untuk akadmin

---

*Last updated: 2026-06-17*