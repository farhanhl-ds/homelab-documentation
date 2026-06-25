# Update Service

Prosedur update Docker container pada homelab secara aman dengan meminimalkan downtime dan risiko incompatibility.

Prosedur ini berlaku untuk seluruh service yang berjalan menggunakan Docker Compose.

---

## Update Strategy

Sebelum melakukan update, pahami tipe service:

| Service Type | Contoh | Risk Level |
|---|---|---|
| Stateless | Homepage, NPM, Uptime Kuma | 🟢 Low |
| Stateful | Vaultwarden, Outline, Postiz | 🟡 Medium |
| Database | PostgreSQL, Redis | 🔴 High |

Untuk service dengan data penting (database, password manager, knowledge base), pastikan backup tersedia sebelum update.

---

## Phase 1 — Check Current Status

Masuk ke LXC yang berisi service:

```bash
pct enter <CT_ID>
```

Contoh:

```bash
pct enter 101
```

Masuk ke folder stack:

```bash
cd /opt/stacks/<service>
```

Cek container yang sedang berjalan:

```bash
docker compose ps
```

Pastikan seluruh container berstatus:

```text
Up
```

---

## Phase 2 — Create Backup (Recommended)

Untuk service penting:

- PostgreSQL
- Redis
- Vaultwarden
- Outline
- Postiz

Pastikan backup terbaru tersedia.

Lihat prosedur lengkap:

```text
Runbooks/disaster-recovery.md
```

> Jangan melakukan major update tanpa memiliki backup yang sudah diverifikasi.

---

## Phase 3 — Pull Latest Image

Download image terbaru:

```bash
docker compose pull
```

Cek image yang berhasil di-download:

```bash
docker compose images
```

---

## Phase 4 — Recreate Container

Lakukan recreate container menggunakan image baru:

```bash
docker compose up -d
```

Docker Compose akan:
- Membuat container baru apabila image berubah.
- Mempertahankan volume data.
- Menghapus container lama secara otomatis.

---

## Phase 5 — Verify Container Health

Cek status:

```bash
docker compose ps
```

Cek log apabila diperlukan:

```bash
docker compose logs --tail=50
```

Pastikan tidak terdapat:
- Crash loop
- Database migration error
- Permission error
- Environment variable error

---

## Phase 6 — Verify Application Access

Lakukan pengecekan sesuai service.

### Core Infrastructure

- Pihole:
  - DNS resolution berfungsi
  - Dashboard dapat diakses

- NPM:
  - Semua proxy host online
  - SSL certificate aktif

- Homepage:
  - Dashboard tampil normal

- Uptime Kuma:
  - Semua monitor kembali online

---

### Security

- Vaultwarden:
  - Login berhasil
  - Password vault dapat dibuka

---

### Database

- PostgreSQL:
  - Database dapat menerima koneksi

- Redis:
  - Service lain dapat melakukan koneksi

- Adminer:
  - Login berhasil

---

### Authentication

- Authentik:
  - Admin UI dapat diakses
  - Login SSO berhasil

---

### Productivity

- Outline:
  - Login melalui Authentik berhasil
  - Document dapat dibuka dan dibuat

- Stirling PDF:
  - Web UI dapat diakses

- Postiz:
  - Login berhasil
  - Social account masih terhubung

---

## Phase 7 — Remove Unused Images

Setelah yakin update berhasil:

Lihat image yang tidak digunakan:

```bash
docker image ls
```

Bersihkan image lama:

```bash
docker image prune -a
```

> ⚠️ Perintah ini akan menghapus semua Docker image yang tidak digunakan oleh container aktif.

---

## Rollback Procedure

Apabila update menyebabkan masalah:

1. Stop container:

```bash
docker compose down
```

2. Restore image sebelumnya.

3. Restore data dari backup apabila diperlukan.

> Untuk service kritikal seperti PostgreSQL dan Vaultwarden, selalu prioritaskan recovery dari backup yang valid.

---

## Update Frequency

| Service | Recommendation |
|---|---|
| NPM | Monthly |
| Homepage | Monthly |
| Uptime Kuma | Monthly |
| Portainer | Monthly |
| Vaultwarden | Monthly |
| PostgreSQL | Quarterly setelah membaca release notes |
| Redis | Quarterly |
| Authentik | Quarterly dan baca breaking changes |
| Outline | Quarterly dan test SSO setelah update |
| Postiz | Saat diperlukan |

---

## Important Notes

- Jangan update seluruh homelab sekaligus.
- Update satu service, lakukan verifikasi, lalu lanjut ke service berikutnya.
- Hindari menggunakan `:latest` tanpa membaca changelog untuk service yang sangat kritikal.
- Selalu simpan credential dan backup sebelum melakukan perubahan besar.

---

*Last updated: 2026-06-18*