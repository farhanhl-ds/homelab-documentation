LXC 103 menjalankan PostgreSQL, Redis, dan Adminer sebagai pusat database untuk seluruh service homelab.

> **Pastikan LXC 102 (Vaultwarden) sudah running** sebelum deploy LXC ini — seluruh password database yang di-generate harus langsung disimpan di Vaultwarden.

## Specs

| | |
|---|---|
| CT ID | 103 |
| Hostname | database |
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
| IP | 192.168.100.103/24 |
| Gateway | 192.168.100.1 |
| DNS | 192.168.100.101 |
| Search domain | homelab.local |

> Untuk langkah pembuatan LXC step by step, lihat [create-lxc-guide.md](../runbooks/create-lxc-guide.md).

---

## Services

### PostgreSQL 16 + Redis + Adminer

| Service | Port | URL |
|---|---|---|
| PostgreSQL | 5432 | — (internal only) |
| Redis | 6379 | — (internal only) |
| Adminer | 8080 | https://adminer.homelab.local |

Path: `/opt/stacks/database/`

### .env

```bash
nano /opt/stacks/database/.env
```

```env
POSTGRES_PASSWORD=your_superuser_password
REDIS_PASSWORD=your_redis_password
```

> Simpan kedua password ini di Vaultwarden → folder Homelab → Note "Database Credentials".

### docker-compose.yml

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
    volumes:
      - ./pgdata:/var/lib/postgresql/data
      - ./init:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    container_name: redis
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - ./redisdata:/data
    ports:
      - "6379:6379"

  adminer:
    image: adminer:latest
    container_name: adminer
    restart: unless-stopped
    ports:
      - "8080:8080"
    depends_on:
      - postgres

volumes: {}
```

> Password PostgreSQL dan Redis menggunakan `.env` file — tidak hardcode di dalam yaml.

### init.sql

```bash
nano /opt/stacks/database/init/init.sql
```

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

> `init.sql` hanya dieksekusi sekali saat volume PostgreSQL masih kosong. Password di sini hardcoded karena PostgreSQL tidak mendukung environment variable di init script. Simpan seluruh password di Vaultwarden.

### Deploy

```bash
cd /opt/stacks/database
docker compose up -d
docker compose ps
```

### Verifikasi via Adminer

Buka `https://adminer.homelab.local`, login:

| Field | Value |
|---|---|
| System | PostgreSQL |
| Server | postgres |
| Username | postgres |
| Password | (superuser password) |
| Database | (kosongkan) |

Konfirmasi `db_authentik`, `db_outline`, `db_postiz`, `db_umami` muncul di daftar database.

---

### Redis Database Index Convention

| Service | Redis DB Index |
|---|---|
| Outline | 0 |
| Postiz | 1 |
| Authentik | 2 |
| (reserved) | 3+ |

---

## Tambah Database Baru

Apabila `init.sql` sudah pernah dieksekusi (volume tidak kosong), tambah database baru via:

```bash
docker exec -it postgres psql -U postgres
```

```sql
CREATE USER new_user WITH PASSWORD 'new_password';
CREATE DATABASE db_new OWNER new_user;
\q
```

---

## Akses dari LXC Lain

| Service | Connection String |
|---|---|
| PostgreSQL | `postgresql://user:password@192.168.100.103:5432/db_name` |
| Redis | `redis://:your_redis_password@192.168.100.103:6379/db_index` |

---

## Post-Deploy Checklist

- [x] Semua container running (postgres, redis, adminer)
- [x] Semua database terbuat (db_authentik, db_outline, db_postiz, db_umami)
- [x] Semua password disimpan di Vaultwarden (Note: Database Credentials)
- [x] Adminer accessible di `https://adminer.homelab.local`
- [x] Test koneksi dari LXC 104 (Authentik)
- [x] Test koneksi dari LXC 105 (Outline)
- [ ] Test koneksi dari LXC 106 (Postiz)

---

*Last updated: 2026-06-16*
