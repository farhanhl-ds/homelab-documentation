# Outline Deployment

Panduan deployment Outline sebagai knowledge base self-hosted dengan login menggunakan Authentik melalui OpenID Connect (OIDC).

Outline berjalan pada LXC 105 (`productivity`).

---

## Prerequisites

Pastikan:

- LXC 105 sudah dibuat
- Docker sudah terinstall
- PostgreSQL dan Redis pada LXC 103 sudah berjalan
- Database `db_outline` dan user `outline_user` sudah tersedia
- Authentik sudah berjalan dan OIDC Provider untuk Outline sudah dibuat
- DNS record `outline.homelab.local` dan `auth.homelab.local` sudah tersedia
- SSL certificate `homelab-local` sudah tersedia di NPM

Referensi:

- `create-lxc-guide.md`
- `docker-installation.md`
- `database-deployment.md`
- `authentik-deployment.md`

---

## 1. Create Stack Directory

```bash
mkdir -p /opt/stacks/outline/data
cd /opt/stacks/outline
```

---

## 2. Generate Secret Keys

Generate dua secret:

```bash
openssl rand -hex 32
openssl rand -hex 32
```

Gunakan untuk:

- `SECRET_KEY`
- `UTILS_SECRET`

Simpan di Vaultwarden:

```text
Homelab
└── Outline
    ├── SECRET_KEY
    ├── UTILS_SECRET
    ├── OIDC_CLIENT_ID
    └── OIDC_CLIENT_SECRET
```

---

## 3. Create `.env`

Buat file:

```bash
nano .env
```

Isi:

```env
SECRET_KEY=your_secret_key
UTILS_SECRET=your_utils_secret

DATABASE_URL=postgres://outline_user:db_password@192.168.100.103:5432/db_outline

REDIS_URL=redis://:redis_password@192.168.100.103:6379/0

URL=https://outline.homelab.local

OIDC_CLIENT_ID=your_client_id
OIDC_CLIENT_SECRET=your_client_secret

OIDC_AUTH_URI=https://auth.homelab.local/application/o/authorize/
OIDC_TOKEN_URI=https://auth.homelab.local/application/o/token/
OIDC_USERINFO_URI=https://auth.homelab.local/application/o/userinfo/
OIDC_LOGOUT_URI=https://auth.homelab.local/application/o/outline/end-session/
```

---

## Important Password Note

Jangan menggunakan password database atau Redis yang mengandung karakter seperti:

```
/ + = @ :
```

Karena karakter tersebut dapat merusak format URL connection string.

Gunakan password berbentuk hexadecimal:

```bash
openssl rand -hex 32
```

Jika password sudah terlanjur dibuat dengan special character, ubah melalui PostgreSQL:

```bash
docker exec -it postgres psql -U postgres
```

Lalu:

```sql
ALTER USER outline_user WITH PASSWORD 'new_hex_password';
\q
```

---

## 4. Create `docker-compose.yml`

Buat file:

```bash
nano docker-compose.yml
```

Isi:

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
      NODE_ENV: "production"

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

      NODE_TLS_REJECT_UNAUTHORIZED: "0"

    volumes:
      - ./data:/var/lib/outline/data

    dns:
      - 192.168.100.101
```

---

## Why These Settings Exist

### `dns: 192.168.100.101`

Docker container tidak otomatis menggunakan DNS LXC.

Tanpa konfigurasi ini, Outline gagal melakukan lookup:

```
auth.homelab.local
```

Error yang muncul:

```text
ENOTFOUND auth.homelab.local
```

---

### `NODE_TLS_REJECT_UNAUTHORIZED=0`

Diperlukan karena Authentik menggunakan SSL self-signed.

Tanpa ini, Outline gagal melakukan komunikasi HTTPS ke endpoint OIDC dengan error certificate validation.

Konfigurasi ini aman untuk jaringan homelab internal.

---

## 5. Deploy Outline

Jalankan:

```bash
docker compose up -d
```

Periksa status:

```bash
docker ps
```

Cek log apabila ada error:

```bash
docker logs outline --tail 50
```

---

## 6. Configure NPM Proxy Host

Buat Proxy Host:

| Field | Value |
|---|---|
| Domain | outline.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.105 |
| Forward Port | 3000 |
| Websocket Support | Enable |
| SSL | homelab-local |
| Force SSL | Enable |

---

## 7. Test Login Flow

Akses:

```
https://outline.homelab.local
```

Expected flow:

```text
User
 ↓
Outline
 ↓
Authentik Login
 ↓
OIDC Callback
 ↓
Outline Dashboard
```

Pastikan:

- Redirect ke Authentik berhasil
- Login berhasil
- User otomatis dibuat di Outline

---

## Troubleshooting

### `ENOTFOUND auth.homelab.local`

Periksa DNS dalam container:

```bash
docker exec -it outline sh
```

Kemudian:

```bash
nslookup auth.homelab.local
```

Solusi:

Periksa:

```yaml
dns:
  - 192.168.100.101
```

---

### `SELF_SIGNED_CERT_IN_CHAIN`

Pastikan:

```env
NODE_TLS_REJECT_UNAUTHORIZED=0
```

sudah berada pada environment container.

---

### Redirect ke halaman error Authentik

Periksa endpoint:

```
https://auth.homelab.local/application/o/outline/
```

Pastikan nilai:

```json
authorization_endpoint
```

mengarah ke:

```
https://auth.homelab.local/application/o/authorize/
```

Jangan menggunakan endpoint yang berbeda.

---

## Security Notes

- Simpan seluruh secret di Vaultwarden
- Jangan commit `.env` ke GitHub
- Gunakan password hexadecimal untuk connection string
- Backup folder `./data` secara berkala

---

## Post-Deployment Checklist

- [ ] Container Outline running
- [ ] Outline dapat diakses via HTTPS
- [ ] Redirect ke Authentik berhasil
- [ ] Login OIDC berhasil
- [ ] User pertama berhasil dibuat
- [ ] Secret disimpan di Vaultwarden
- [ ] Backup strategy dibuat

---

## Next Step

Setelah Outline selesai, lanjutkan deployment service lain di LXC 105:

1. Stirling PDF
2. Postiz

Runbook berikutnya:

`stirling-pdf-deployment.md`

---

*Last updated: 2026-06-18*