LXC 105 menjalankan seluruh service aplikasi: Outline (knowledge base), Stirling PDF (PDF tools), dan Postiz (social media scheduler).

> **Pastikan LXC 103 (database) dan LXC 104 (auth) sudah running** sebelum deploy LXC ini.

## Specs

| | |
|---|---|
| CT ID | 105 |
| Hostname | productivity |
| OS | Ubuntu 24.04 LTS |
| CPU | 2 cores |
| RAM | 1024MB |
| Swap | 512MB |
| Disk | 16GB (local-lvm) |
| Unprivileged | Yes |
| Nesting | Yes (Docker) |

## Network

| | |
|---|---|
| IP | 192.168.100.105/24 |
| Gateway | 192.168.100.1 |
| DNS | 192.168.100.101 |
| Search domain | homelab.local |

## Dependencies

| Service | Host | Catatan |
|---|---|---|
| PostgreSQL | 192.168.100.103:5432 | db_outline, db_postiz |
| Redis | 192.168.100.103:6379 | db index 0 (Outline), db index 1 (Postiz) |
| Authentik | 192.168.100.104:9000 | OIDC provider untuk Outline |

> Untuk langkah pembuatan LXC step by step, lihat [create-lxc-guide.md](../runbooks/create-lxc-guide.md).

---

## Services

### Outline

| | |
|---|---|
| URL | https://outline.homelab.local |
| Path | /opt/stacks/outline/ |
| Status | ✅ Done |

#### Generate Secret Keys

```bash
openssl rand -hex 32  # SECRET_KEY
openssl rand -hex 32  # UTILS_SECRET
```

Simpan ke Vaultwarden sebelum melanjutkan.

#### .env

```bash
nano /opt/stacks/outline/.env
```

```env
SECRET_KEY=your_secret_key
UTILS_SECRET=your_utils_secret
DATABASE_URL=postgres://outline_user:password@192.168.100.103:5432/db_outline
REDIS_URL=redis://:redis_password@192.168.100.103:6379/0
OIDC_CLIENT_ID=your_client_id
OIDC_CLIENT_SECRET=your_client_secret
URL=https://outline.homelab.local
OIDC_AUTH_URI=https://auth.homelab.local/application/o/authorize/
OIDC_TOKEN_URI=https://auth.homelab.local/application/o/token/
OIDC_USERINFO_URI=https://auth.homelab.local/application/o/userinfo/
OIDC_LOGOUT_URI=https://auth.homelab.local/application/o/outline/end-session/
```

> ⚠️ **Password database dan Redis tidak boleh mengandung special characters** (`/`, `+`, `=`, dll) karena akan menyebabkan URL parsing error. Generate ulang apabila terdapat special characters:
> ```bash
> docker exec -it postgres psql -U postgres -c "ALTER USER outline_user WITH PASSWORD 'new_hex_password';"
> ```

> **OIDC_AUTH_URI yang benar:** `https://auth.homelab.local/application/o/authorize/`
> Verifikasi via `https://auth.homelab.local/application/o/outline/` → lihat field `authorization_endpoint`

#### docker-compose.yml

```yaml
services:
  outline:
    image: outlinewiki/outline:latest
    container_name: outline
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      SECRET_KEY: ${SECRET_KEY}
      UTILS_SECRET: ${UTILS_SECRET}
      DATABASE_URL: ${DATABASE_URL}
      REDIS_URL: ${REDIS_URL}
      URL: ${URL}
      PORT: "3000"
      FORCE_HTTPS: "true"
      PGSSLMODE: "disable"
      FILE_STORAGE: local
      FILE_STORAGE_LOCAL_ROOT_DIR: /var/lib/outline/data
      OIDC_CLIENT_ID: ${OIDC_CLIENT_ID}
      OIDC_CLIENT_SECRET: ${OIDC_CLIENT_SECRET}
      OIDC_AUTH_URI: ${OIDC_AUTH_URI}
      OIDC_TOKEN_URI: ${OIDC_TOKEN_URI}
      OIDC_USERINFO_URI: ${OIDC_USERINFO_URI}
      OIDC_LOGOUT_URI: ${OIDC_LOGOUT_URI}
      OIDC_DISPLAY_NAME: "Homelab SSO"
      OIDC_SCOPES: "openid profile email"
      NODE_ENV: "production"
      NODE_TLS_REJECT_UNAUTHORIZED: "0"
    volumes:
      - ./data:/var/lib/outline/data
    dns:
      - 192.168.100.101

volumes: {}
```

> **`NODE_TLS_REJECT_UNAUTHORIZED: "0"`** — menonaktifkan TLS verification untuk koneksi internal ke Authentik yang menggunakan self-signed certificate. Aman untuk jaringan homelab internal.
>
> **`dns: 192.168.100.101`** — container Outline memerlukan resolusi `auth.homelab.local` via Pihole. Tanpa konfigurasi ini, OIDC callback akan gagal dengan error `ENOTFOUND`.

#### Deploy

```bash
cd /opt/stacks/outline
docker compose up -d
docker compose logs outline --tail=20
```

#### Setup NPM Proxy Host

| Field | Value |
|---|---|
| Domain | outline.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.105 |
| Forward Port | 3000 |
| Websockets | ✅ |
| SSL | homelab-local |
| Force SSL | ✅ |

---

### Stirling PDF

| | |
|---|---|
| URL | https://stirling.homelab.local |
| Path | /opt/stacks/stirling-pdf/ |
| Status | 🔲 Pending |

```yaml
services:
  stirling-pdf:
    image: frooodle/s-pdf:latest
    container_name: stirling-pdf
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - ./trainingData:/usr/share/tessdata
      - ./configs:/configs

volumes: {}
```

```bash
cd /opt/stacks/stirling-pdf
docker compose up -d
```

---

### Postiz

| | |
|---|---|
| URL | https://postiz.homelab.local |
| Path | /opt/stacks/postiz/ |
| Status | 🔲 Pending |

#### Generate JWT Secret

```bash
openssl rand -hex 32  # JWT_SECRET
```

Simpan ke Vaultwarden sebelum melanjutkan.

#### docker-compose.yml

```yaml
services:
  postiz:
    image: ghcr.io/gitroomhq/postiz-app:latest
    container_name: postiz
    restart: unless-stopped
    ports:
      - "3001:3000"
    environment:
      DATABASE_URL: "postgresql://postiz_user:postiz_password@192.168.100.103:5432/db_postiz"
      REDIS_URL: "redis://:your_redis_password@192.168.100.103:6379/1"
      JWT_SECRET: "your_jwt_secret"
      NEXT_PUBLIC_BACKEND_URL: "https://postiz.homelab.local"
      FRONTEND_URL: "https://postiz.homelab.local"
      BACKEND_INTERNAL_URL: "http://localhost:3000"
    volumes:
      - ./uploads:/app/uploads
    dns:
      - 192.168.100.101

volumes: {}
```

> ⚠️ **Deploy Postiz setelah NPM proxy host dan SSL sudah dikonfigurasi.** `NEXT_PUBLIC_BACKEND_URL` dan `FRONTEND_URL` harus menggunakan HTTPS domain sejak awal — apabila diset ke HTTP terlebih dahulu, dapat menyebabkan redirect loop dan session error setelah SSL diaktifkan.

> Port Postiz menggunakan `3001:3000` (host port 3001) agar tidak konflik dengan Outline yang menggunakan port 3000.

#### Setup NPM Proxy Host

| Field | Value |
|---|---|
| Domain | postiz.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.105 |
| Forward Port | 3001 |
| Websockets | ✅ |
| SSL | homelab-local |
| Force SSL | ✅ |

---

## Post-Deploy Checklist

- [x] Outline accessible di `https://outline.homelab.local`
- [x] Login via Authentik SSO berhasil
- [ ] Stirling PDF accessible di `https://stirling.homelab.local`
- [ ] Setup NPM proxy host untuk Stirling PDF
- [ ] Deploy Postiz
- [ ] Setup NPM proxy host untuk Postiz
- [ ] Setup OIDC provider Postiz di Authentik (lihat [lxc-104-auth.md](./lxc-104-auth.md))
- [ ] Connect social media accounts di Postiz

---

*Last updated: 2026-06-16*
