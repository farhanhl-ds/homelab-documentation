# Disaster Recovery

Panduan pemulihan homelab apabila terjadi kegagalan hardware, kerusakan storage, kehilangan data, atau kegagalan konfigurasi besar.

---

## Recovery Strategy

Homelab menggunakan dua metode recovery:

### Method A — Restore Proxmox LXC Backup (Preferred)

Digunakan apabila backup LXC masih tersedia.

Keuntungan:

- Recovery cepat
- Seluruh konfigurasi container ikut kembali
- Docker environment, volume, dan aplikasi tidak perlu di-deploy ulang

Target Recovery Time:

- ±30–60 menit untuk seluruh homelab

---

### Method B — Documentation-Driven Rebuild

Digunakan apabila:

- Backup LXC rusak
- Migrasi ke hardware baru
- Ingin melakukan clean rebuild

Recovery dilakukan menggunakan dokumentasi GitHub sebagai source of truth.

Target Recovery Time:

- Beberapa jam hingga 1 hari tergantung jumlah data yang perlu di-restore

---

# Scenario 1 — Proxmox Host Failure

Contoh:

- SSD Proxmox rusak
- Instalasi Proxmox corrupt
- Hardware diganti

---

## Step 1 — Reinstall Proxmox

Install Proxmox VE pada storage baru.

Pastikan:

- BIOS setting sesuai `infrastructure/proxmox.md`
- Network configuration menggunakan subnet `192.168.100.0/24`
- Hostname kembali menjadi:

```
haytham.homelab.local
```

---

## Step 2 — Restore LXC Backup

Restore seluruh container dengan urutan:

| Order | LXC | Role |
|---|---|---|
| 1 | 101 | Core Infrastructure |
| 2 | 102 | Security |
| 3 | 103 | Database |
| 4 | 104 | Identity |
| 5 | 105 | Productivity |

Pastikan setiap LXC memiliki:

- CT ID yang sama
- IP address yang sama
- Startup order yang sama

Referensi:
- `infrastructure/proxmox.md`
- `services/*.md`

---

## Step 3 — Verify Infrastructure

Pastikan service berikut dapat diakses:

### Core Infrastructure

- Pihole DNS berjalan
- NPM dashboard dapat dibuka
- SSL certificate tersedia

---

### Security

- Vaultwarden login berhasil

---

### Database

- PostgreSQL berjalan
- Redis berjalan

---

### Identity

- Authentik login berhasil

---

### Applications

- Outline login menggunakan SSO berhasil
- Stirling PDF dapat dibuka
- Postiz dapat diakses

---

# Scenario 2 — Rebuild From Documentation

Gunakan apabila backup LXC tidak tersedia.

---

## Step 1 — Restore Repository

Clone repository documentation:

```bash
git clone <repository-url>
```

Pastikan seluruh folder tersedia:

```
Infrastructure/
Services/
Runbooks/
```

---

## Step 2 — Install Proxmox

Ikuti:

```
Infrastructure/proxmox.md
```

---

## Step 3 — Recreate LXC

Buat ulang:

| CT ID | Hostname |
|---|---|
| 101 | core-infra |
| 102 | security |
| 103 | database |
| 104 | auth |
| 105 | productivity |

Ikuti:

```
Runbooks/Installation/create-lxc-guide.md
```

---

## Step 4 — Install Docker

Install Docker pada seluruh LXC yang membutuhkan.

Referensi:

```
Runbooks/Installation/docker-installation.md
```

---

## Step 5 — Deploy Services

Ikuti urutan berikut:

| Order | Service |
|---|---|
| 1 | Pihole |
| 2 | Nginx Proxy Manager |
| 3 | Vaultwarden |
| 4 | PostgreSQL + Redis |
| 5 | Authentik |
| 6 | Outline |
| 7 | Stirling PDF |
| 8 | Postiz |

Referensi:

```
Runbooks/Deployment/
```

---

## Step 6 — Restore Application Data

Restore:

| Component | Data |
|---|---|
| Vaultwarden | Database dan attachment |
| PostgreSQL | Database dump |
| Redis | Redis dump |
| NPM | Configuration dan certificate |
| Pihole | DNS configuration |
| Authentik | Media files |
| Outline | Attachment |
| Postiz | Upload file |

---

# Emergency Credentials

Beberapa credential tidak boleh hanya bergantung pada Vaultwarden.

Simpan backup offline untuk:

- Proxmox root password
- Vaultwarden master password
- Database superuser password
- Backup storage password
- GitHub account recovery code
- SSL private key

Lokasi penyimpanan:

```
Offline encrypted backup
+
Physical copy (optional)
```

---

# Recovery Validation Checklist

## Infrastructure

- [ ] Semua LXC running
- [ ] Startup order telah dikonfigurasi
- [ ] DNS resolution berjalan
- [ ] HTTPS certificate valid

---

## Security

- [ ] Vaultwarden dapat login
- [ ] 2FA recovery tersedia

---

## Database

- [ ] PostgreSQL database lengkap
- [ ] Redis dapat diakses

---

## Identity

- [ ] Authentik login berhasil
- [ ] OIDC provider berfungsi

---

## Applications

- [ ] Outline dapat login melalui Authentik
- [ ] Dokumen dan attachment tersedia
- [ ] Stirling PDF berjalan
- [ ] Postiz dapat login dan data tersedia

---

# Disaster Recovery Test

Backup dianggap valid hanya apabila proses restore pernah diuji.

Disarankan melakukan:

- Restore test minimal setiap 6 bulan
- Verifikasi seluruh service setelah restore
- Update dokumentasi apabila ditemukan perubahan proses

---

# Important Notes

- Jangan melakukan perubahan besar tanpa membuat backup terlebih dahulu.
- Jangan menyimpan `.env`, database dump, atau private key di repository GitHub.
- Selalu update dokumentasi apabila ada perubahan architecture.

---

*Last updated: 2026-06-18*