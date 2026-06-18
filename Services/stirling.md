# Stirling PDF

Stirling PDF merupakan self-hosted PDF processing platform yang menyediakan berbagai tool untuk mengelola dan memodifikasi dokumen PDF secara lokal tanpa perlu menggunakan layanan pihak ketiga.

Seluruh proses dokumen dilakukan di dalam environment homelab sehingga file sensitif tidak perlu di-upload ke layanan cloud eksternal.

## Service Information

| Component | Details |
|---|---|
| Service | Stirling PDF |
| Deployment | Docker Container |
| Host Node | LXC 105 — Productivity |
| Access URL | https://stirling.homelab.local |
| Internal Port | 8080 |
| Authentication | Local access (no SSO) |

---

## Purpose

Stirling PDF digunakan untuk berbagai kebutuhan pemrosesan dokumen seperti:

- Merge dan split PDF
- Compress PDF
- Convert format dokumen
- OCR (Optical Character Recognition)
- Rotate, crop, dan edit halaman PDF
- Menambahkan atau menghapus password PDF

Stirling PDF berfungsi sebagai utility service dan tidak menjadi dependency bagi aplikasi lain dalam homelab.

---

## Data & Storage

Stirling PDF menggunakan local volume untuk menyimpan konfigurasi dan data tambahan.

Direktori yang digunakan:

```text
/opt/stacks/stirling-pdf/
```

Contoh data yang tersimpan:

- Konfigurasi aplikasi
- OCR training data (Tesseract)
- Custom configuration file

Sebagian besar dokumen yang diproses bersifat temporary dan tidak menjadi bagian dari persistent application database.

---

## Access Model

Akses dilakukan melalui HTTPS menggunakan reverse proxy dari Nginx Proxy Manager.

```text
User Browser
      |
      v
Nginx Proxy Manager
      |
      v
Stirling PDF
```

Tidak ada komunikasi dengan database ataupun external identity provider.

---

## Security Considerations

### Document Privacy

Keuntungan utama self-hosted Stirling PDF:

- Dokumen tetap berada di jaringan internal
- Tidak dikirim ke layanan PDF online pihak ketiga
- Data sensitif dapat diproses secara privat

### Access Control

Saat ini akses menggunakan jaringan internal homelab melalui HTTPS.

Apabila Stirling PDF digunakan oleh banyak user di masa depan, integrasi dengan Authentik dapat dipertimbangkan untuk menyediakan Single Sign-On (SSO).

---

## Dependency Relationship

### Depends On

- LXC 101 — Core Infrastructure
  - Pi-hole untuk DNS resolution
  - Nginx Proxy Manager untuk HTTPS reverse proxy

- LXC 102 — Security
  - Vaultwarden untuk penyimpanan credential atau API key apabila diperlukan di masa depan

---

### Required By

- Homelab administrator untuk kebutuhan pengolahan dokumen PDF

Kegagalan Stirling PDF tidak berdampak terhadap aplikasi atau service lain dalam homelab.

---

## Backup Requirement

Backup Stirling PDF bersifat opsional dan bergantung pada penggunaan.

Direkomendasikan untuk membackup:

- Application configuration
- OCR training data
- Custom settings

File dokumen hasil proses umumnya tidak perlu dibackup apabila hanya digunakan sebagai temporary workspace.

---

## Future Improvement

Beberapa peningkatan yang dapat dipertimbangkan:

- Integrasi Single Sign-On (SSO) menggunakan Authentik
- Menambahkan access policy untuk multi-user environment
- Menambahkan storage khusus apabila digunakan sebagai document workspace permanen

---

## Related Runbooks

- `Runbooks/stirling-pdf-deployment.md` — Deployment dan initial configuration.
- `Runbooks/stirling-pdf-maintenance.md` — Update, backup, dan maintenance.

---

*Last updated: 2026-06-18*