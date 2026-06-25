# Service Migration Procedure

Panduan melakukan migrasi service antar LXC atau server baru dengan aman tanpa kehilangan data dan konfigurasi.

---

## Related Documents

- `Runbooks/Operations/backup-restore.md`
- `Runbooks/Operations/shutdown-procedure.md`
- `Runbooks/Operations/power-recovery.md`
- `Runbooks/Configuration/npm-proxy-host.md`

---

# Migration Overview

Proses migrasi mengikuti urutan berikut:

```text
Preparation
     |
     v
Backup Service Data
     |
     v
Prepare Target Environment
     |
     v
Transfer Data
     |
     v
Deploy Service
     |
     v
Update DNS / Reverse Proxy
     |
     v
Validation
     |
     v
Decommission Old Service
```

---

# Phase 1 — Preparation

Identifikasi service yang akan dipindahkan.

Catat:

- Nama service
- Source LXC
- Destination LXC
- IP lama dan baru
- Port service
- Domain yang digunakan
- Database dependency
- Redis dependency
- Docker volume yang digunakan

Contoh:

| Item | Value |
|---|---|
| Service | Postiz |
| Source | LXC 106 |
| Destination | LXC 105 |
| Domain | postiz.homelab.local |
| Database | db_postiz |
| Redis | Redis DB 1 |

---

# Phase 2 — Create Backup

Stop service untuk memastikan data konsisten.

Masuk ke source LXC:

```bash
pct enter <SOURCE_ID>
```

Stop Docker container:

```bash
docker compose down
```

Backup folder service:

```bash
tar -czf service-backup.tar.gz /opt/stacks/<service>
```

Pastikan file backup berhasil dibuat:

```bash
ls -lh service-backup.tar.gz
```

---

# Phase 3 — Prepare Target LXC

Pastikan target sudah memiliki:

- Docker Engine
- Docker Compose
- DNS access
- Network connectivity ke database dan Redis

Verifikasi:

```bash
docker --version
docker compose version
ping 192.168.100.103
```

---

# Phase 4 — Transfer Data

Transfer backup dari source ke target.

Contoh menggunakan SCP:

Dari source:

```bash
scp service-backup.tar.gz root@192.168.100.105:/root/
```

Atau dari Proxmox host:

```bash
scp root@SOURCE_IP:/root/service-backup.tar.gz \
    root@TARGET_IP:/root/
```

---

# Phase 5 — Restore Service Data

Masuk ke target LXC:

```bash
pct enter <TARGET_ID>
```

Extract backup:

```bash
tar -xzf /root/service-backup.tar.gz -C /
```

Verifikasi:

```bash
ls /opt/stacks/<service>
```

Pastikan terdapat:

- docker-compose.yml
- .env
- volume data

---

# Phase 6 — Deploy Service

Masuk ke directory service:

```bash
cd /opt/stacks/<service>
```

Jalankan:

```bash
docker compose up -d
```

Verifikasi:

```bash
docker ps
docker compose logs --tail=50
```

Pastikan tidak terdapat error.

---

# Phase 7 — Update Reverse Proxy

Apabila IP service berubah, update konfigurasi Nginx Proxy Manager.

Contoh:

Sebelum:

```text
Forward Host:
192.168.100.106:3001
```

Sesudah:

```text
Forward Host:
192.168.100.105:3001
```

Pastikan:

- Domain tetap sama
- SSL certificate tetap aktif
- Websocket tetap sesuai kebutuhan

---

# Phase 8 — Validation

Lakukan pengecekan:

## Service

- [ ] Halaman aplikasi dapat diakses
- [ ] Login berhasil
- [ ] Data lama masih tersedia
- [ ] Upload dan perubahan baru berhasil disimpan

---

## Dependency

- [ ] Koneksi PostgreSQL berhasil
- [ ] Koneksi Redis berhasil
- [ ] DNS resolution berhasil

---

## Monitoring

- [ ] Uptime Kuma menunjukkan status UP

---

# Phase 9 — Decommission Old Service

Jangan langsung menghapus source.

Tunggu minimal 24 jam setelah migrasi berhasil.

Setelah yakin:

Stop container lama:

```bash
docker compose down
```

Backup final:

```bash
tar -czf final-archive.tar.gz /opt/stacks/<service>
```

Hapus service lama apabila tidak diperlukan:

```bash
rm -rf /opt/stacks/<service>
```

---

# Rollback Procedure

Apabila migration gagal:

1. Matikan service baru:

```bash
docker compose down
```

2. Jalankan kembali service lama:

```bash
docker compose up -d
```

3. Kembalikan Nginx Proxy Manager ke IP lama.

---

# Migration Checklist

## Before Migration

- [ ] Backup telah dibuat
- [ ] Target LXC siap
- [ ] Dependency PostgreSQL tersedia
- [ ] Dependency Redis tersedia
- [ ] DNS dan NPM configuration dicatat

---

## After Migration

- [ ] Service berjalan normal
- [ ] Data berhasil dipindahkan
- [ ] Domain dapat diakses
- [ ] Monitoring menunjukkan status healthy
- [ ] Old service sudah diarsipkan atau dihapus

---

# Important Notes

- Selalu lakukan backup sebelum migration.
- Jangan menghapus source service sebelum melakukan validasi.
- Pertahankan domain yang sama untuk menghindari perubahan konfigurasi client.
- Gunakan downtime maintenance window apabila service memiliki banyak pengguna.

---

*Last updated: 2026-06-19*