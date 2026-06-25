# Postiz Deployment

Panduan deployment Postiz sebagai aplikasi social media scheduler self-hosted.

Postiz berjalan pada LXC 105 (`productivity`).

---

## Prerequisites

Pastikan:

- LXC 105 sudah dibuat
- Docker sudah terinstall
- PostgreSQL dan Redis pada LXC 103 sudah berjalan
- Database `db_postiz` dan user `postiz_user` sudah tersedia
- DNS record `postiz.homelab.local` sudah dibuat di Pihole
- NPM Proxy Host dan SSL certificate `homelab-local` sudah disiapkan sebelum final setup

Referensi:

- `create-lxc-guide.md`
- `docker-installation.md`
- `database-deployment.md`
- `nginx-proxy-manager-deployment.md`

---

## 1. Create Stack Directory

```bash
mkdir -p /opt/stacks/postiz
cd /opt/stacks/postiz
```

---

## 2. Generate JWT Secret

Generate JWT secret:

```bash
openssl rand -hex 32
```

Simpan ke Vaultwarden:

```
Homelab
└── Postiz
    ├── JWT_SECRET
    ├── Database Password
    └── Redis Password
```

---

## 3. Create `.env`

Buat file:

```bash
nano .env
```

Isi:

```env
DATABASE_URL=postgresql://postiz_user:your_database_password@192.168.100.103:5432/db_postiz

REDIS_URL=redis://:your_redis_password@192.168.100.103:6379/1

JWT_SECRET=your_jwt_secret

NEXT_PUBLIC_BACKEND_URL=https://postiz.homelab.local
FRONTEND_URL=https://postiz.homelab.local

BACKEND_INTERNAL_URL=http://localhost:3000
```

---

## 4. Create `docker-compose.yml`

Buat:

```bash
nano docker-compose.yml
```

Isi:

```yaml
services:
  postiz:
    image: ghcr.io/gitroomhq/postiz-app:latest
    container_name: postiz
    restart: unless-stopped

    ports:
      - "3001:3000"

    env_file:
      - .env

    volumes:
      - ./uploads:/app/uploads

    dns:
      - 192.168.100.101
```

---

## Why `dns: 192.168.100.101`?

Docker container tidak selalu menggunakan DNS dari host LXC.

Dengan menggunakan Pihole sebagai DNS, Postiz dapat melakukan resolusi domain internal seperti:

```
auth.homelab.local
```

Hal ini akan dibutuhkan apabila Postiz diintegrasikan dengan Authentik menggunakan OIDC.

---

## 5. Deploy Container

Jalankan:

```bash
docker compose up -d
```

Verifikasi:

```bash
docker ps
```

Atau cek log:

```bash
docker logs postiz --tail 50
```

Pastikan tidak ada error terkait:

- PostgreSQL connection
- Redis connection
- JWT secret
- URL configuration

---

## 6. Configure Nginx Proxy Manager

Buat Proxy Host:

| Field | Value |
|---|---|
| Domain | postiz.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.105 |
| Forward Port | 3001 |
| Websocket Support | Enable |
| SSL Certificate | homelab-local |
| Force SSL | Enable |

---

## 7. Verify Access

Buka:

```
https://postiz.homelab.local
```

Pastikan:

- Login page muncul
- HTTPS menggunakan certificate `homelab-local`
- Tidak terjadi redirect loop
- Session dapat dibuat dengan normal

---

## Optional: Integrate with Authentik OIDC

Postiz dapat diintegrasikan dengan Authentik agar menggunakan Single Sign-On (SSO).

Konfigurasi OIDC dilakukan setelah deployment Postiz selesai dan akan menggunakan:

```
Authentik
     |
     | OIDC
     |
Postiz
```

Konfigurasi detail dibuat pada runbook terpisah apabila fitur ini digunakan.

---

## Backup Strategy

Backup directory berikut:

```
/opt/stacks/postiz
```

Data yang tersimpan:

- Upload file
- Environment configuration
- Docker compose configuration

---

## Troubleshooting

### Redirect loop atau session error

Periksa:

```env
NEXT_PUBLIC_BACKEND_URL
FRONTEND_URL
```

Pastikan keduanya menggunakan:

```
https://postiz.homelab.local
```

Jangan menggunakan:

```
http://
192.168.100.x
localhost
```

---

### Tidak dapat terkoneksi ke database

Test dari container:

```bash
docker exec -it postiz sh
```

Cek koneksi ke PostgreSQL:

```bash
nc -zv 192.168.100.103 5432
```

---

### Tidak dapat resolve domain internal

Periksa:

```yaml
dns:
  - 192.168.100.101
```

Test:

```bash
docker exec -it postiz nslookup auth.homelab.local
```

---

## Security Notes

- Jangan commit `.env` ke GitHub
- Simpan JWT secret di Vaultwarden
- Gunakan password database yang kuat
- Backup folder `/opt/stacks/postiz` secara berkala

---

## Post-Deployment Checklist

- [ ] Container Postiz running
- [ ] PostgreSQL connection berhasil
- [ ] Redis connection berhasil
- [ ] Postiz accessible via HTTPS
- [ ] NPM Proxy Host dikonfigurasi
- [ ] JWT secret disimpan di Vaultwarden
- [ ] Test login dan session berhasil
- [ ] Integrasi OIDC dengan Authentik (opsional)
- [ ] Social media accounts berhasil dikoneksi

---

## Next Step

Deployment layer LXC 105 selesai.

Lanjutkan ke:

- Setup OIDC Postiz dengan Authentik (opsional)
- Konfigurasi social media accounts
- Menyusun backup dan disaster recovery strategy

---

*Last updated: 2026-06-18*