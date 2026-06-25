# Authentik Deployment

Panduan deployment Authentik sebagai Identity Provider (IdP) dan OpenID Connect (OIDC) provider untuk seluruh service homelab.

Authentik berjalan pada LXC 104 (`auth`).

---

## Prerequisites

Pastikan:

- LXC 104 sudah dibuat
- Docker sudah terinstall
- PostgreSQL dan Redis di LXC 103 sudah berjalan
- Database `db_authentik` dan user `authentik_user` sudah tersedia
- DNS record `auth.homelab.local` sudah dibuat
- SSL certificate `homelab-local` sudah tersedia di NPM

Referensi:

- `create-lxc-guide.md`
- `docker-installation.md`
- `database-deployment.md`
- `nginx-proxy-manager-deployment.md`

---

## 1. Create Stack Directory

```bash
mkdir -p /opt/stacks/authentik
cd /opt/stacks/authentik

mkdir media custom-templates certs
```

---

## 2. Fix Directory Permission

Authentik container berjalan menggunakan UID 1000.

Set permission sebelum deploy:

```bash
chown -R 1000:1000 media custom-templates certs
```

Tanpa langkah ini Authentik dapat gagal dengan error:

```text
PermissionError: /media/public
```

---

## 3. Generate Secret Key

Generate secret:

```bash
openssl rand -hex 32
```

Simpan ke Vaultwarden:

```
Homelab
└── Authentik
    └── SECRET_KEY
```

---

## 4. Create `.env`

Buat:

```bash
nano .env
```

Isi:

```env
AUTHENTIK_POSTGRESQL__PASSWORD=authentik_db_password
AUTHENTIK_REDIS__PASSWORD=redis_password
AUTHENTIK_SECRET_KEY=your_secret_key

AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS=192.168.100.0/24
```

---

### Trusted Proxy Configuration

Karena Authentik berjalan di belakang NPM, Authentik harus mempercayai `X-Forwarded-*` header.

Tanpa konfigurasi ini:

- CSS tidak termuat
- JavaScript tidak berjalan
- UI tampil sebagai plain text

---

## 5. Create `docker-compose.yml`

Buat:

```bash
nano docker-compose.yml
```

Isi:

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
      AUTHENTIK_POSTGRESQL__HOST: 192.168.100.103
      AUTHENTIK_POSTGRESQL__USER: authentik_user
      AUTHENTIK_POSTGRESQL__NAME: db_authentik
      AUTHENTIK_POSTGRESQL__PASSWORD: ${AUTHENTIK_POSTGRESQL__PASSWORD}

      AUTHENTIK_REDIS__HOST: 192.168.100.103
      AUTHENTIK_REDIS__PORT: 6379
      AUTHENTIK_REDIS__PASSWORD: ${AUTHENTIK_REDIS__PASSWORD}
      AUTHENTIK_REDIS__DB: 2

      AUTHENTIK_SECRET_KEY: ${AUTHENTIK_SECRET_KEY}

      AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS: ${AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS}

      AUTHENTIK_ERROR_REPORTING__ENABLED: "false"

    volumes:
      - ./media:/media
      - ./custom-templates:/templates


  authentik-worker:
    image: ghcr.io/goauthentik/server:latest
    container_name: authentik-worker
    command: worker
    restart: unless-stopped

    environment:
      AUTHENTIK_POSTGRESQL__HOST: 192.168.100.103
      AUTHENTIK_POSTGRESQL__USER: authentik_user
      AUTHENTIK_POSTGRESQL__NAME: db_authentik
      AUTHENTIK_POSTGRESQL__PASSWORD: ${AUTHENTIK_POSTGRESQL__PASSWORD}

      AUTHENTIK_REDIS__HOST: 192.168.100.103
      AUTHENTIK_REDIS__PORT: 6379
      AUTHENTIK_REDIS__PASSWORD: ${AUTHENTIK_REDIS__PASSWORD}
      AUTHENTIK_REDIS__DB: 2

      AUTHENTIK_SECRET_KEY: ${AUTHENTIK_SECRET_KEY}

      AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS: ${AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS}

      AUTHENTIK_ERROR_REPORTING__ENABLED: "false"

    volumes:
      - ./media:/media
      - ./custom-templates:/templates
      - ./certs:/certs
```

---

## 6. Deploy Authentik

Jalankan:

```bash
docker compose up -d
```

Cek log:

```bash
docker compose logs -f authentik-server
```

Tunggu sampai tidak ada error.

---

## 7. Initial Setup

Akses langsung melalui IP:

```
http://192.168.100.104:9000/if/flow/initial-setup/
```

Buat:

- Username admin
- Password admin
- Email administrator

Simpan credential di Vaultwarden.

---

## 8. Configure Nginx Proxy Manager

Buat Proxy Host:

| Field | Value |
|---|---|
| Domain | auth.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.104 |
| Forward Port | 9000 |
| Websocket Support | Enable |
| SSL | homelab-local |
| Force SSL | Enable |

---

### Custom Nginx Configuration

Tab **Advanced**:

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Host $host;
```

Tanpa header ini Authentik dapat salah membaca request dari reverse proxy.

---

## 9. Configure Brand Domain

Login Admin:

```
https://auth.homelab.local/if/admin/
```

Buka:

```
System
 → Brands
 → authentik-default
```

Set:

```
Domain:
auth.homelab.local
```

Simpan perubahan.

---

## 10. Create OIDC Provider

Contoh untuk Outline.

Buka:

```
Applications
 → Providers
 → Create
 → OAuth2/OpenID Provider
```

Konfigurasi:

| Field | Value |
|---|---|
| Name | outline-provider |
| Authorization Flow | default-provider-authorization-explicit-consent |
| Client Type | Confidential |
| Redirect URI | https://outline.homelab.local/auth/oidc.callback |

Simpan.

Catat:

- Client ID
- Client Secret

Simpan ke Vaultwarden.

---

## 11. Create Application

Buka:

```
Applications
 → Applications
 → Create
```

Isi:

| Field | Value |
|---|---|
| Name | Outline |
| Slug | outline |
| Provider | outline-provider |

---

## 12. Verify OIDC Endpoint

Buka:

```
https://auth.homelab.local/application/o/outline/
```

Pastikan terdapat:

```json
authorization_endpoint:
https://auth.homelab.local/application/o/authorize/
```

Gunakan URL tersebut pada aplikasi client.

---

## Important Notes

### Jangan menggunakan:

```env
AUTHENTIK_HOST
AUTHENTIK_HOST_BROWSER
```

Environment tersebut dapat menyebabkan redirect loop ketika menggunakan reverse proxy.

---

## Security Hardening

Disarankan setelah setup:

- Enable 2FA untuk akun administrator
- Buat group administrator terpisah
- Backup database Authentik secara rutin

---

## Troubleshooting

### UI tampil sebagai plain text

Periksa:

- `AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS`
- Custom NPM header

Restart:

```bash
docker compose restart
```

---

### Tidak dapat konek ke database

Test dari container:

```bash
docker exec -it authentik-server bash
```

Test koneksi:

```bash
nc -zv 192.168.100.103 5432
```

---

### Login loop

Pastikan environment berikut **tidak ada**:

```env
AUTHENTIK_HOST
AUTHENTIK_HOST_BROWSER
```

---

## Post-Deployment Checklist

- [ ] Container authentik-server running
- [ ] Container authentik-worker running
- [ ] Initial setup selesai
- [ ] Authentik dapat diakses via HTTPS
- [ ] Brand domain dikonfigurasi
- [ ] NPM custom header dikonfigurasi
- [ ] OIDC provider untuk Outline dibuat
- [ ] Client ID & Secret disimpan di Vaultwarden
- [ ] 2FA admin diaktifkan

---

## Next Step

Setelah Authentik siap:

Deploy aplikasi yang menggunakan SSO.

Urutan:

1. Outline
2. Postiz
3. Service lain menggunakan OIDC

Runbook berikutnya:

`outline-deployment.md`

---

*Last updated: 2026-06-18*