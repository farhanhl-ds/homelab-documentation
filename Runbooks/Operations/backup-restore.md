# Backup and Restore Procedure

Panduan melakukan backup dan restore data homelab untuk memastikan seluruh service dapat dipulihkan setelah terjadi kegagalan hardware, kerusakan sistem, atau migrasi server.

---

## Related Documents

- `Infrastructure/backup.md`
- `Runbooks/disaster-recovery.md`
- `Runbooks/Operations/power-recovery.md`

---

# Backup Strategy

Backup dilakukan pada beberapa layer:

```text
Proxmox Host
       |
       ├── LXC Configuration
       |
       ├── LXC Backup Archive
       |
       └── Docker Service Data
               |
               ├── Application Data
               ├── Database
               └── Configuration Files
```

---

# Backup Scope

## 1. Proxmox Configuration

Backup konfigurasi LXC:

```bash
/etc/pve/lxc/
```

Mencakup:

- CPU
- RAM
- Disk
- Network
- Startup order
- Mount point

Verifikasi:

```bash
ls /etc/pve/lxc/
```

---

## 2. LXC Backup

Gunakan fitur backup Proxmox.

Contoh backup LXC:

```bash
vzdump 101 --compress zstd --mode snapshot
```

Contoh backup seluruh LXC:

```bash
vzdump 101 102 103 104 105 --compress zstd --mode snapshot
```

Backup akan menghasilkan file:

```text
vzdump-lxc-xxx.tar.zst
```

---

## 3. Docker Service Data

Seluruh Docker stack menggunakan struktur:

```text
/opt/stacks/
```

Folder ini wajib dibackup karena berisi:

- docker-compose.yml
- .env
- application data
- uploaded files
- service configuration

Contoh:

```text
/opt/stacks
├── pihole
├── npm
├── homepage
├── uptime-kuma
├── portainer
├── vaultwarden
├── database
├── authentik
├── outline
├── stirling-pdf
└── postiz
```

Backup menggunakan tar:

```bash
tar -czf homelab-stacks-backup.tar.gz /opt/stacks
```

---

# Database Backup

## PostgreSQL

Masuk ke LXC Database:

```bash
pct enter 103
```

Backup seluruh database:

```bash
docker exec postgres pg_dumpall -U postgres > postgres-backup.sql
```

Backup file harus disimpan di lokasi external sebelum keluar dari LXC.

---

## Redis

Masuk ke LXC Database:

```bash
pct enter 103
```

Trigger save:

```bash
docker exec redis redis-cli \
  -a your_redis_password SAVE
```

File database Redis:

```text
/opt/stacks/database/redisdata/dump.rdb
```

Backup file tersebut ke storage eksternal.

---

# Service Specific Backup

## Vaultwarden

Path penting:

```text
/opt/stacks/vaultwarden/data
```

Berisi:

- SQLite database
- Attachments
- Configuration

---

## Authentik

Backup utama:

- PostgreSQL database `db_authentik`
- Folder:

```text
/opt/stacks/authentik/media
```

---

## Outline

Backup utama:

- PostgreSQL database `db_outline`
- Folder:

```text
/opt/stacks/outline/data
```

---

## Postiz

Backup utama:

- PostgreSQL database `db_postiz`
- Folder:

```text
/opt/stacks/postiz/uploads
```

---

# Backup Frequency Recommendation

| Data | Frequency |
|---|---|
| Proxmox LXC Backup | Weekly |
| PostgreSQL Dump | Daily |
| Docker Stack Data | Weekly |
| Vaultwarden Data | Daily |
| Critical Configuration | Setelah perubahan besar |

---

# Restore Procedure

## Scenario 1 — Restore Entire LXC

Gunakan backup Proxmox:

```bash
pct restore <new_id> vzdump-lxc-xxx.tar.zst
```

Verifikasi:

```bash
pct list
```

Pastikan LXC berhasil berjalan.

---

## Scenario 2 — Restore Docker Stack

Restore folder:

```text
/opt/stacks
```

Kemudian masuk ke setiap stack:

```bash
cd /opt/stacks/<service>
docker compose up -d
```

Verifikasi:

```bash
docker ps
```

---

## Scenario 3 — Restore PostgreSQL

Copy file:

```text
postgres-backup.sql
```

Kemudian:

```bash
docker exec -i postgres psql -U postgres < postgres-backup.sql
```

Verifikasi database:

```bash
docker exec -it postgres psql -U postgres -l
```

---

## Scenario 4 — Restore Redis

Stop Redis:

```bash
docker stop redis
```

Restore file:

```text
dump.rdb
```

ke:

```text
/opt/stacks/database/redisdata/
```

Start kembali:

```bash
docker start redis
```

---

# Post-Restore Validation

## Infrastructure

- [ ] DNS Pi-hole berfungsi
- [ ] Nginx Proxy Manager berjalan
- [ ] HTTPS certificate valid

---

## Security

- [ ] Vaultwarden dapat login
- [ ] Authentik dapat login

---

## Applications

- [ ] Outline dapat diakses
- [ ] Stirling PDF dapat diakses
- [ ] Postiz dapat diakses

---

## Monitoring

- [ ] Uptime Kuma menunjukkan seluruh service UP

---

# Backup Storage Recommendation

Jangan menyimpan seluruh backup pada server yang sama.

Gunakan salah satu:

- External HDD / SSD
- NAS
- Remote storage
- Cloud storage dengan encryption

---

# Important Notes

- Backup tanpa test restore dianggap belum tervalidasi.
- Selalu lakukan test restore secara berkala.
- Simpan password backup dan encryption key di Vaultwarden.
- Dokumentasikan perubahan besar sebelum melakukan migration atau upgrade.

---

*Last updated: 2026-06-19*