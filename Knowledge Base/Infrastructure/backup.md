# Backup Strategy

Strategi backup untuk seluruh komponen homelab, termasuk konfigurasi infrastructure, database, aplikasi, dan secret.

Tujuan utama backup adalah memastikan seluruh service dapat dipulihkan apabila terjadi kegagalan hardware, kesalahan konfigurasi, atau kehilangan data.

---

## Backup Principles

Homelab menggunakan strategi backup berlapis:

1. **LXC backup menggunakan Proxmox Backup**
   - Digunakan sebagai metode recovery tercepat.
   - Seluruh filesystem, konfigurasi LXC, dan Docker environment ikut tersimpan.

2. **Documentation-driven rebuild**
   - Repository GitHub digunakan sebagai source of truth untuk melakukan rebuild dari nol apabila backup LXC tidak tersedia atau saat migrasi ke hardware baru.

3. **Application data backup**
   - Data penting seperti database, credential, dan file upload memiliki backup terpisah untuk mengurangi risiko kehilangan data.

---

## Backup Targets

| Component | Data | Priority |
|---|---|---|
| Proxmox LXC | Seluruh container backup (`.tar.zst`) | 🔴 Critical |
| LXC 101 — core-infra | Pihole config, NPM data, SSL certificate | 🔴 Critical |
| LXC 102 — security | Vaultwarden database dan attachment | 🔴 Critical |
| LXC 103 — database | PostgreSQL dump, Redis data | 🔴 Critical |
| LXC 104 — auth | Authentik media dan configuration | 🟡 Important |
| LXC 105 — productivity | Outline attachment, Postiz upload | 🟡 Important |
| Documentation | GitHub repository | 🔴 Critical |

---

## Backup Schedule

| Backup Type | Frequency |
|---|---|
| Proxmox LXC backup | Weekly |
| PostgreSQL dump | Daily |
| Vaultwarden backup | Daily |
| Critical Docker volume backup | Weekly |
| GitHub repository | Real-time (git commit & push) |

---

## Backup Location

| Storage | Purpose |
|---|---|
| Proxmox local storage | Temporary backup storage |
| External HDD / SSD | Primary backup destination |
| GitHub repository | Documentation dan configuration history |

---

## Retention Policy

| Backup | Retention |
|---|---|
| Daily backup | 7 hari terakhir |
| Weekly backup | 4 minggu terakhir |
| Manual snapshot sebelum perubahan besar | Disimpan sampai perubahan dianggap stabil |

---

## Recovery Priority

Apabila terjadi total failure, service dipulihkan dengan urutan berikut:

1. **Core Infrastructure**
   - Pihole
   - Nginx Proxy Manager
   - SSL certificate

2. **Security**
   - Vaultwarden

3. **Database**
   - PostgreSQL
   - Redis

4. **Identity**
   - Authentik

5. **Applications**
   - Outline
   - Stirling PDF
   - Postiz

---

## Important Notes

- Backup tidak dianggap valid apabila belum pernah dilakukan proses restore test.
- Secret dan password tidak boleh hanya bergantung pada satu lokasi penyimpanan.
- Repository GitHub tidak boleh menyimpan `.env`, database dump, atau private key.
- Sebelum melakukan perubahan besar pada infrastructure, buat backup manual terlebih dahulu.

---

*Last updated: 2026-06-18*