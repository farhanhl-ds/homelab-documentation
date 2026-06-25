# Adminer

Adminer menyediakan web-based database administration interface untuk mengelola, melakukan verifikasi, dan troubleshooting database dalam environment homelab.

Adminer digunakan sebagai alat administrasi dan bukan sebagai bagian dari application data layer.

## Service Information

| Component | Details |
|---|---|
| Service | Adminer |
| Deployment | Docker Container |
| Host Node | LXC 103 — Database |
| Internal Port | 8080 |
| Access URL | https://adminer.homelab.local |
| Access Type | Internal HTTPS only |

## Purpose

Adminer digunakan untuk melakukan operasi administrasi database seperti:

- Verifikasi database dan user yang telah dibuat
- Melakukan query SQL manual untuk kebutuhan troubleshooting
- Melihat struktur database, table, dan schema
- Memastikan konektivitas aplikasi ke PostgreSQL

Adminer tidak digunakan oleh aplikasi secara langsung dan tidak memiliki peran dalam proses runtime aplikasi.

---

## Access Model

Administrator mengakses Adminer melalui HTTPS yang disediakan oleh Nginx Proxy Manager:

```text
Administrator Browser
          |
          |
https://adminer.homelab.local
          |
          |
 Nginx Proxy Manager
          |
          |
        Adminer
          |
          |
      PostgreSQL
```

Adminer hanya digunakan untuk mengelola PostgreSQL yang berada pada LXC 103.

---

## Authentication Model

Adminer tidak memiliki user management internal.

Akses database dilakukan menggunakan credential PostgreSQL yang valid.

Contoh login:

| Field | Value |
|---|---|
| System | PostgreSQL |
| Server | `postgres` |
| Username | PostgreSQL user |
| Password | Credential dari Vaultwarden |
| Database | Opsional |

Karena Adminer menggunakan credential database secara langsung, keamanan akun PostgreSQL menjadi bagian penting dari keamanan Adminer.

---

## Security Considerations

### Network Exposure

Adminer tidak boleh diekspos langsung ke internet.

Akses dilakukan melalui:

- Internal network homelab
- HTTPS reverse proxy melalui Nginx Proxy Manager
- SSL certificate `homelab-local`

### Credential Handling

Adminer tidak menyimpan password PostgreSQL secara permanen.

Semua credential database harus:

- Dibuat dengan prinsip least privilege
- Disimpan di Vaultwarden
- Tidak di-hardcode dalam konfigurasi aplikasi

### Administrative Access

Karena Adminer dapat melakukan operasi langsung terhadap database, akses hanya boleh diberikan kepada administrator yang dipercaya.

---

## Dependencies

### Depends On

- Docker Engine pada LXC 103
- PostgreSQL untuk database management
- LXC 101 — Core Infrastructure:
  - Pi-hole untuk DNS resolution
  - Nginx Proxy Manager untuk HTTPS access

### Required By

Tidak ada application dependency.

Adminer digunakan oleh homelab administrator untuk:

- Database verification
- Troubleshooting
- Maintenance activity

Kehilangan Adminer tidak menyebabkan aplikasi gagal berjalan karena PostgreSQL tetap dapat diakses menggunakan command-line tools.

---

## Backup Requirement

Adminer tidak menyimpan application data yang bersifat kritikal.

Backup khusus Adminer tidak diperlukan.

Apabila terjadi kerusakan atau kehilangan container, Adminer dapat dibuat ulang menggunakan deployment configuration yang sama.

---

## Related Runbooks

- `Runbooks/adminer-deployment.md` — Deployment, initial access, dan verification.
- `Runbooks/postgresql-maintenance.md` — Database maintenance dan administrative operation.

---

*Last updated: 2026-06-17*