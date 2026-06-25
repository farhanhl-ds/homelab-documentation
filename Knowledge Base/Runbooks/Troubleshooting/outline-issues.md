# Outline Issues

Troubleshooting masalah Outline yang berkaitan dengan PostgreSQL, DNS internal, SSL/TLS, OIDC Authentik, dan konfigurasi HTTPS.

Masalah pada layer ini biasanya muncul ketika:

* Container Outline gagal start.
* Login melalui Authentik gagal.
* Redirect OIDC menampilkan error.
* Database tidak dapat diakses.
* HTTPS dan secure cookie tidak berjalan.

---

# Outline restart terus setelah deployment pertama

## Symptoms

* Container `outline` terus restart.
* Status pada Docker:

```text
Restarting
```

---

## Diagnosis

Periksa log:

```bash
docker compose logs outline --tail=50
```

Error yang sering muncul:

```text
The server does not support SSL connections
```

atau:

```text
Gracefully quitting
```

---

## Root Cause

Outline secara default mencoba menggunakan koneksi PostgreSQL dengan SSL.

Namun PostgreSQL internal Homelab berjalan tanpa SSL.

---

## Resolution

Tambahkan environment variable:

```env
PGSSLMODE=disable
```

Kemudian lakukan recreate:

```bash
docker compose up -d --force-recreate
```

---

# Outline tidak dapat resolve domain internal Authentik

## Symptoms

Log menunjukkan error:

```text
ENOTFOUND auth.homelab.local
```

---

## Root Cause

Docker menggunakan internal DNS resolver (`127.0.0.11`) dan tidak mengetahui domain internal `.homelab.local`.

---

## Resolution

Tambahkan DNS server Pi-hole pada `docker-compose.yml`:

```yaml
services:
  outline:
    dns:
      - 192.168.100.101
```

Lakukan recreate:

```bash
docker compose up -d --force-recreate
```

---

# Outline gagal melakukan OIDC karena self-signed certificate

## Symptoms

Login melalui Authentik gagal.

Log dapat menunjukkan error seperti:

```text
SELF_SIGNED_CERT_IN_CHAIN
```

atau TLS validation error.

---

## Root Cause

Node.js di dalam container Outline tidak mempercayai self-signed certificate yang digunakan oleh Authentik.

---

## Resolution

Tambahkan environment variable:

```env
NODE_TLS_REJECT_UNAUTHORIZED=0
```

Kemudian recreate container:

```bash
docker compose up -d --force-recreate
```

---

# Redirect OIDC menampilkan halaman Not Found

## Symptoms

User berhasil diarahkan ke Authentik tetapi setelah proses login muncul halaman:

```text
Not Found
```

---

## Root Cause

Nilai `OIDC_AUTH_URI` menggunakan endpoint yang salah.

Contoh yang salah:

```text
/application/o/outline/authorize/
```

---

## Resolution

Gunakan endpoint authorization dari Authentik discovery endpoint.

Contoh yang benar:

```env
OIDC_AUTH_URI=https://auth.homelab.local/application/o/authorize/
```

Pastikan juga endpoint berikut sesuai:

* `OIDC_TOKEN_URI`
* `OIDC_USERINFO_URI`

---

# Outline gagal membuat secure cookie

## Symptoms

Log menampilkan:

```text
Error: Cannot send secure cookie over unencrypted connection
```

---

## Root Cause

Outline menganggap request yang diterima tidak menggunakan HTTPS.

Penyebab umum:

* URL masih menggunakan IP.
* `FORCE_HTTPS` belum aktif.
* Reverse Proxy belum dikonfigurasi dengan benar.

---

## Resolution

Pastikan konfigurasi environment:

```env
URL=https://outline.homelab.local

FORCE_HTTPS=true
```

Periksa juga:

* Nginx Proxy Manager menggunakan HTTPS.
* Certificate telah terpasang dengan benar.
* Header reverse proxy berjalan normal.

---

# Database password gagal dibaca karena karakter khusus

## Symptoms

Outline gagal melakukan koneksi PostgreSQL setelah mengganti password.

---

## Root Cause

Connection string PostgreSQL menggunakan format URL.

Karakter seperti:

* `/`
* `+`
* `=`
* `@`

dapat menyebabkan parsing URL menjadi tidak valid.

---

## Resolution

Gunakan password dengan format hexadecimal:

```bash
openssl rand -hex 16
```

Setelah mengganti password:

1. Update password PostgreSQL.
2. Update file `.env` Outline.
3. Update `init.sql` apabila melakukan deployment ulang.

---

# Verification Checklist

Setelah seluruh konfigurasi benar:

| Check                           | Expected Result                                       |
| ------------------------------- | ----------------------------------------------------- |
| `docker ps`                     | Container `outline` status `Up`                       |
| `docker compose logs outline`   | Tidak ada error                                       |
| `https://outline.homelab.local` | Website dapat dibuka                                  |
| Login SSO                       | Berhasil redirect ke Authentik dan kembali ke Outline |
| Document access                 | Dapat membuka dan membuat document baru               |

---

# Prevention

* Gunakan password database yang URL-safe.
* Dokumentasikan seluruh OIDC endpoint.
* Gunakan DNS internal yang dapat diakses dari seluruh container yang membutuhkan.
* Jangan melakukan restart berulang tanpa membaca log.
* Pisahkan troubleshooting berdasarkan layer: Database → DNS → TLS → OIDC → Application.

---

# Related Documents

* `Services/outline.md`
* `Services/postgresql.md`
* `Services/authentik.md`
* `Runbooks/Deployment/outline-deployment.md`
* `Runbooks/Configurations/authentik-oidc.md`
* `Troubleshooting/authentik-issues.md`
* `Troubleshooting/docker-issues.md`
* `Troubleshooting/certificate-issues.md`

---

# Incident History

## 2026-06-15 — Initial Outline deployment

### Root Causes

* PostgreSQL SSL mode tidak sesuai.
* Container tidak dapat resolve domain internal Authentik.
* Self-signed certificate tidak dipercaya oleh Node.js.
* OIDC authorization endpoint salah.
* Database password mengandung karakter yang bermasalah.

### Resolution

* Tambahkan `PGSSLMODE=disable`.
* Tambahkan DNS Pi-hole ke Docker Compose.
* Tambahkan `NODE_TLS_REJECT_UNAUTHORIZED=0`.
* Perbaiki `OIDC_AUTH_URI`.
* Ganti password menjadi format hexadecimal.

### Lessons Learned

Outline merupakan service yang melewati banyak layer dependency.

Gunakan urutan diagnosis berikut:

```text
Container Status
       ↓
Docker Logs
       ↓
PostgreSQL Connection
       ↓
DNS Resolution
       ↓
TLS Validation
       ↓
OIDC Flow
       ↓
Application Configuration
```

---

*Last updated: 2026-06-20*
