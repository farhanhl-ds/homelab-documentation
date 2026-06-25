# Redis

Redis menyediakan in-memory datastore untuk cache, session storage, dan temporary data bagi application service dalam environment homelab.

Redis digunakan untuk meningkatkan performa aplikasi dengan menyimpan data yang membutuhkan akses cepat tanpa harus selalu melakukan query ke database utama.

## Service Information

| Component | Details |
|---|---|
| Service | Redis |
| Deployment | Docker Container |
| Host Node | LXC 103 — Database |
| Version | Redis 7 |
| Internal Port | 6379 |
| External Access | Internal network only |

## Purpose

Redis digunakan sebagai data layer berkecepatan tinggi untuk kebutuhan seperti:

- Application cache
- User session storage
- Temporary data
- Message queue (apabila diperlukan)
- Background job coordination

Redis bukan pengganti PostgreSQL dan tidak digunakan sebagai primary persistent database.

---

## Connection Model

Service lain mengakses Redis melalui internal network:

```text
Application Container
          |
          |
192.168.100.103:6379
          |
          |
        Redis
```

Format koneksi:

```text
redis://:password@192.168.100.103:6379/database_index
```

Redis credential disimpan secara terpusat di Vaultwarden.

---

## Redis Database Index Convention

Untuk menjaga isolasi antar aplikasi, setiap service menggunakan Redis database index yang berbeda.

| Application | Redis DB Index |
|---|---|
| Outline | `0` |
| Postiz | `1` |
| Authentik | `2` |
| Reserved | `3+` |

Apabila terdapat aplikasi baru yang membutuhkan Redis, gunakan database index berikutnya yang masih tersedia.

---

## Data Storage

Redis menggunakan persistent storage untuk menyimpan data pada:

```text
/opt/stacks/database/redisdata/
```

Direktori ini dapat berisi:

- Redis snapshot (RDB)
- Append-only files (AOF) apabila diaktifkan
- Persistence metadata

Data Redis perlu dipertimbangkan dalam proses backup sesuai kebutuhan aplikasi yang menggunakannya.

---

## Security Model

### Authentication

Akses Redis dilindungi menggunakan password (`requirepass`).

Password Redis:
- Tidak disimpan secara hardcoded dalam Docker Compose
- Disimpan melalui `.env` saat deployment
- Disimpan secara permanen di Vaultwarden

### Network Exposure

Redis hanya dapat diakses melalui internal network homelab.

Tidak ada akses langsung dari internet atau port forwarding ke Redis.

---

## Dependencies

### Depends On

- Docker Engine pada LXC 103
- Persistent storage pada LXC 103
- Vaultwarden untuk penyimpanan Redis credential

### Required By

- LXC 104 — Authentication (Authentik cache dan session storage)
- LXC 105 — Productivity (Outline, Postiz, dan aplikasi lain yang membutuhkan Redis)

Kegagalan Redis dapat menyebabkan aplikasi yang bergantung padanya mengalami masalah cache, session, atau background job.

---

## Backup Requirement

Tingkat kebutuhan backup Redis bergantung pada jenis data yang disimpan oleh aplikasi.

Untuk environment ini, backup Redis tetap direkomendasikan karena dapat menyimpan:

- Session data
- Job queue
- Temporary application state

Backup Redis sebaiknya dilakukan bersamaan dengan backup PostgreSQL agar konsistensi data antar service tetap terjaga.

---

## Related Runbooks

- `Runbooks/redis-deployment.md` — Deployment Redis, password configuration, dan initial setup.
- `Runbooks/redis-maintenance.md` — Update, backup, restore, dan Redis administration.

---

*Last updated: 2026-06-17*