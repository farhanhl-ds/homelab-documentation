# Database Deployment

Panduan deployment PostgreSQL, Redis, dan Adminer sebagai database layer utama untuk seluruh service homelab.

Database berjalan pada LXC 103 (`database`).

---

## Prerequisites

Pastikan:

- LXC 103 sudah dibuat
- Docker sudah terinstall
- Vaultwarden sudah berjalan

Semua password yang di-generate selama deployment harus langsung disimpan ke Vaultwarden.

Referensi:

- `create-lxc-guide.md`
- `docker-installation.md`
- `vaultwarden-deployment.md`

---

## 1. Create Stack Directory

```bash
mkdir -p /opt/stacks/database/init
cd /opt/stacks/database
```

---

## 2. Generate Credentials

Generate password untuk:

- PostgreSQL superuser
- Redis
- Database user tiap aplikasi

Gunakan format hexadecimal agar aman digunakan pada connection string.

Contoh:

```bash
openssl rand -hex 32
```

Buat dan simpan:

```
Homelab
└── Database Credentials
    ├── postgres
    ├── redis
    ├── authentik_user
    ├── outline_user
    ├── postiz_user
    └── umami_user
```

---

## 3. Create `.env`

Buat file:

```bash
nano .env
```

Isi:

```env
POSTGRES_PASSWORD=postgres_superuser_password
REDIS_PASSWORD=redis_password
```

> Jangan commit file `.env` ke GitHub karena berisi secret.

---

## 4. Create `init.sql`

Buat file:

```bash
nano init/init.sql
```

Isi:

```sql
-- Authentik
CREATE USER authentik_user WITH PASSWORD 'authentik_password';
CREATE DATABASE db_authentik OWNER authentik_user;

-- Outline
CREATE USER outline_user WITH PASSWORD 'outline_password';
CREATE DATABASE db_outline OWNER outline_user;

-- Postiz
CREATE USER postiz_user WITH PASSWORD 'postiz_password';
CREATE DATABASE db_postiz OWNER postiz_user;

-- Umami
CREATE USER umami_user WITH PASSWORD 'umami_password';
CREATE DATABASE db_umami OWNER umami_user;
```

> File ini hanya dijalankan saat PostgreSQL pertama kali membuat database volume.

---

## 5. Create `docker-compose.yml`

Buat file:

```bash
nano docker-compose.yml
```

Isi:

```yaml
services:
  postgres:
    image: postgres:16
    container_name: postgres
    restart: unless-stopped

    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      PGDATA: /var/lib/postgresql/data/pgdata

    ports:
      - "5432:5432"

    volumes:
      - ./pgdata:/var/lib/postgresql/data
      - ./init:/docker-entrypoint-initdb.d


  redis:
    image: redis:7-alpine
    container_name: redis
    restart: unless-stopped

    command:
      redis-server --requirepass ${REDIS_PASSWORD}

    ports:
      - "6379:6379"

    volumes:
      - ./redisdata:/data


  adminer:
    image: adminer:latest
    container_name: adminer
    restart: unless-stopped

    ports:
      - "8080:8080"

    depends_on:
      - postgres
```

---

## 6. Deploy Database Stack

Jalankan:

```bash
docker compose up -d
```

Verifikasi:

```bash
docker ps
```

Expected:

```text
postgres   Up
redis      Up
adminer    Up
```

---

## 7. Verify PostgreSQL via Adminer

Buka:

```
http://192.168.100.103:8080
```

Login:

| Field | Value |
|---|---|
| System | PostgreSQL |
| Server | postgres |
| Username | postgres |
| Password | POSTGRES_PASSWORD |
| Database | kosongkan |

Pastikan database berikut tersedia:

- db_authentik
- db_outline
- db_postiz
- db_umami

---

## 8. Redis Database Convention

Gunakan pembagian Redis DB berikut:

| Redis DB | Service |
|---|---|
| 0 | Outline |
| 1 | Postiz |
| 2 | Authentik |
| 3+ | Reserved |

---

## 9. Adding New Database

Apabila PostgreSQL sudah pernah diinisialisasi, `init.sql` tidak akan dijalankan ulang.

Tambahkan database baru secara manual:

Masuk ke PostgreSQL:

```bash
docker exec -it postgres psql -U postgres
```

Buat user:

```sql
CREATE USER new_user WITH PASSWORD 'new_password';
```

Buat database:

```sql
CREATE DATABASE db_new OWNER new_user;

\q
```

---

## 10. Configure Adminer Proxy

Buat Proxy Host di NPM:

| Field | Value |
|---|---|
| Domain | adminer.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.103 |
| Forward Port | 8080 |
| SSL | homelab-local |
| Force SSL | Enable |

---

## Verification

Test dari LXC lain:

PostgreSQL:

```bash
nc -zv 192.168.100.103 5432
```

Redis:

```bash
nc -zv 192.168.100.103 6379
```

Expected:

```
succeeded
```

---

## Security Notes

- Jangan expose PostgreSQL atau Redis ke internet.
- PostgreSQL dan Redis hanya untuk internal network.
- Gunakan password berbeda untuk setiap service.
- Simpan semua credential di Vaultwarden.
- Backup volume `pgdata` secara rutin.

---

## Troubleshooting

### `init.sql` tidak berjalan

Penyebab:

PostgreSQL sudah memiliki data lama.

Periksa:

```bash
docker volume ls
```

atau folder:

```bash
ls -lah ./pgdata
```

Solusi:

Hapus volume hanya apabila data tidak diperlukan.

---

### Connection refused

Periksa container:

```bash
docker ps
```

Cek log:

```bash
docker logs postgres
```

atau:

```bash
docker logs redis
```

---

## Post-Deployment Checklist

- [ ] PostgreSQL berjalan
- [ ] Redis berjalan
- [ ] Adminer berjalan
- [ ] Semua database dibuat
- [ ] Semua credential disimpan di Vaultwarden
- [ ] Adminer dapat diakses via HTTPS
- [ ] Test koneksi dari LXC 104
- [ ] Test koneksi dari LXC 105

---

## Next Step

Setelah database siap:

Deploy Authentik sebagai Identity Provider dan OIDC server.

Runbook berikutnya:

`authentik-deployment.md`

---

*Last updated: 2026-06-18*