# Authentik Issues

Troubleshooting masalah Authentik, mulai dari startup container, koneksi Redis, hingga integrasi dengan reverse proxy.

Masalah pada layer ini biasanya muncul ketika:

* Container Authentik tidak dapat berjalan.
* UI tidak tampil dengan benar.
* Login mengalami redirect loop.
* Authentik gagal terhubung ke Redis.

---

# Authentik container terus restart karena PermissionError

## Symptoms

* Container `authentik-server` atau `authentik-worker` memiliki status:

```text
Restarting
```

* Log menampilkan error seperti:

```text
PermissionError: [Errno 13] Permission denied
```

---

## Root Cause

Volume mount Authentik menggunakan folder:

* `media`
* `custom-templates`
* `certs`

Folder tersebut dibuat dengan ownership yang tidak sesuai sehingga process Authentik (UID `1000`) tidak memiliki izin untuk menulis file.

---

## Diagnosis

Periksa ownership folder:

```bash
ls -lah /opt/stacks/authentik
```

Pastikan folder berikut dapat diakses oleh UID `1000`.

---

## Resolution

Buat folder apabila belum ada:

```bash
mkdir -p \
/opt/stacks/authentik/media \
/opt/stacks/authentik/custom-templates \
/opt/stacks/authentik/certs
```

Ubah ownership:

```bash
chown -R 1000:1000 \
/opt/stacks/authentik/media \
/opt/stacks/authentik/custom-templates \
/opt/stacks/authentik/certs
```

Restart service:

```bash
docker compose restart
```

---

# Authentik menampilkan HTML mentah saat diakses melalui domain

## Symptoms

* Halaman Authentik tampil tanpa CSS.
* Browser hanya menampilkan source HTML.
* JavaScript dan asset tidak berhasil dimuat.

---

## Root Cause

Authentik berada di belakang Nginx Proxy Manager tetapi tidak mempercayai informasi reverse proxy.

Header berikut tidak diteruskan:

* `X-Forwarded-Proto`
* `X-Forwarded-For`
* `Host`

atau trusted proxy belum dikonfigurasi.

---

## Resolution

Pada Nginx Proxy Manager, buka Proxy Host Authentik kemudian tambahkan Custom Nginx Config:

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Host $host;
```

Tambahkan juga pada `.env`:

```env
AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS=192.168.100.0/24
```

Kemudian lakukan recreate:

```bash
docker compose up -d --force-recreate
```

Kedua konfigurasi tersebut harus diterapkan bersamaan.

---

# Authentik gagal terhubung ke Redis setelah password berubah

## Symptoms

* Authentik gagal start.
* Log menampilkan Redis connection error.
* `authentik-server` atau `authentik-worker` restart terus.

---

## Root Cause

Password Redis pada file `.env` Authentik tidak sesuai dengan password Redis yang sedang digunakan.

---

## Resolution

Perbarui konfigurasi:

```env
AUTHENTIK_REDIS__PASSWORD=<redis-password>
```

Setelah itu recreate container:

```bash
docker compose up -d --force-recreate
```

---

# Login mengalami redirect loop

## Symptoms

* Login berhasil menggunakan credential yang benar.
* Browser diarahkan kembali ke halaman login.
* Proses login berulang terus menerus.

Contoh alur:

```text
Login
  ↓
Redirect
  ↓
Login
  ↓
Redirect
```

---

## Root Cause

Variable berikut dikonfigurasi secara manual tanpa kebutuhan khusus:

```env
AUTHENTIK_HOST
AUTHENTIK_HOST_BROWSER
```

Dalam kebanyakan deployment di belakang reverse proxy, Authentik dapat menentukan URL publik dari `X-Forwarded` header.

---

## Resolution

Hapus variable berikut dari `.env` apabila tidak diperlukan:

```env
AUTHENTIK_HOST=
AUTHENTIK_HOST_BROWSER=
```

Kemudian restart Authentik:

```bash
docker compose up -d --force-recreate
```

---

# Verification Checklist

Setelah melakukan perbaikan, pastikan:

| Check                        | Expected Result                                          |
| ---------------------------- | -------------------------------------------------------- |
| `docker ps`                  | `authentik-server` dan `authentik-worker` berstatus `Up` |
| `https://auth.homelab.local` | UI tampil normal                                         |
| CSS dan JavaScript           | Berhasil dimuat                                          |
| Login                        | Tidak terjadi redirect loop                              |
| Redis connection             | Tidak ada error pada log                                 |

---

# Prevention

* Buat folder volume Authentik sebelum menjalankan deployment pertama.
* Dokumentasikan perubahan password Redis dan update seluruh service yang menggunakannya.
* Jangan menambahkan `AUTHENTIK_HOST` dan `AUTHENTIK_HOST_BROWSER` kecuali memang diperlukan.
* Selalu konfigurasi `X-Forwarded` header ketika menggunakan reverse proxy.

---

# Related Documents

* `Services/authentik.md`
* `Runbooks/Deployment/authentik-deployment.md`
* `Runbooks/Configurations/authentik-oidc.md`
* `Troubleshooting/reverse-proxy-issues.md`
* `Troubleshooting/docker-issues.md`

---

# Incident History

## 2026-06-15 — Authentik deployment issues

### Root Causes

* Volume folder memiliki permission yang salah.
* Reverse proxy tidak meneruskan `X-Forwarded` headers.
* Trusted proxy CIDR belum dikonfigurasi.
* Redis password tidak sesuai.
* `AUTHENTIK_HOST` dan `AUTHENTIK_HOST_BROWSER` menyebabkan login loop.

### Resolution

* Perbaiki ownership volume menjadi `1000:1000`.
* Tambahkan `X-Forwarded` headers pada Nginx Proxy Manager.
* Set `AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS=192.168.100.0/24`.
* Sinkronkan password Redis.
* Hapus variable `AUTHENTIK_HOST` yang tidak diperlukan.

### Lessons Learned

Jangan langsung menganggap Authentik rusak.

Lakukan diagnosis sesuai urutan:

```text
Docker
  ↓
Volume Permission
  ↓
Redis Connection
  ↓
Reverse Proxy Header
  ↓
Authentication Flow
```

---

*Last updated: 2026-06-20*
