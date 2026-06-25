# Certificate Issues

Troubleshooting masalah SSL/TLS certificate pada environment Homelab.

Masalah pada layer ini biasanya muncul ketika:

* Domain berhasil di-resolve.
* Nginx Proxy Manager dapat dijangkau.
* Service berjalan normal.
* Tetapi browser menampilkan warning certificate atau HTTPS tidak dapat dikonfigurasi.

---

# Tidak dapat membuat Let's Encrypt certificate untuk `.homelab.local`

## Symptoms

* Nginx Proxy Manager gagal saat memilih **Request a new SSL Certificate**.
* Muncul error ACME validation gagal.
* Certificate tidak pernah berhasil dibuat.

---

## Root Cause

Let's Encrypt hanya dapat melakukan validasi terhadap domain publik yang dapat diakses melalui internet.

Domain internal seperti:

```text
*.homelab.local
```

tidak memiliki DNS publik sehingga tidak dapat diverifikasi oleh Let's Encrypt.

---

# Resolution

Gunakan self-signed wildcard certificate sebagai alternatif.

Generate certificate:

```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /opt/stacks/npm/homelab.key \
  -out /opt/stacks/npm/homelab.crt \
  -subj "/CN=*.homelab.local"
```

Hasil:

```text
homelab.crt
homelab.key
```

---

## Import certificate ke Nginx Proxy Manager

1. Login ke Nginx Proxy Manager.
2. Masuk ke **SSL Certificates**.
3. Pilih **Add SSL Certificate**.
4. Pilih **Custom Certificate**.
5. Upload:

   * `homelab.crt`
   * `homelab.key`

Setelah berhasil di-import, gunakan certificate tersebut pada setiap Proxy Host.

---

# Browser menampilkan warning "Connection is not private"

## Symptoms

Browser menampilkan pesan seperti:

```text
Your connection is not private
NET::ERR_CERT_AUTHORITY_INVALID
```

---

## Root Cause

Self-signed certificate dibuat sendiri dan tidak dipercaya oleh Certificate Authority (CA) publik.

---

## Resolution

Install certificate ke Trusted Root Certificate Store pada client.

### Windows

1. Jalankan `certmgr.msc`.
2. Masuk ke:

```
Trusted Root Certification Authorities
    └── Certificates
```

3. Import file:

```
homelab.crt
```

4. Restart browser.

---

# Certificate tidak sesuai dengan domain

## Symptoms

Browser menampilkan error seperti:

```text
NET::ERR_CERT_COMMON_NAME_INVALID
```

---

## Possible Causes

| Problem                                       | Root Cause                                   |
| --------------------------------------------- | -------------------------------------------- |
| Domain tidak cocok                            | Certificate dibuat untuk domain yang berbeda |
| Menggunakan certificate non-wildcard          | Subdomain baru tidak tercakup                |
| Proxy Host menggunakan certificate yang salah | NPM belum menggunakan certificate yang benar |

---

## Diagnosis

Periksa certificate yang digunakan pada Nginx Proxy Manager:

* Buka Proxy Host.
* Masuk ke tab **SSL**.
* Pastikan certificate yang dipilih adalah wildcard `*.homelab.local`.

---

## Resolution

Gunakan certificate yang sesuai.

Contoh yang benar:

```
Certificate:
*.homelab.local

Domain:
vault.homelab.local
auth.homelab.local
outline.homelab.local
```

---

# Verification Checklist

Setelah konfigurasi selesai:

| Check                   | Expected Result                             |
| ----------------------- | ------------------------------------------- |
| HTTPS dapat dibuka      | Berhasil                                    |
| Browser warning         | Tidak muncul setelah certificate dipercaya  |
| NPM Proxy Host          | Menggunakan wildcard certificate yang benar |
| Semua `*.homelab.local` | Menggunakan certificate yang sama           |

---

# Prevention

* Gunakan satu wildcard certificate untuk seluruh domain internal.
* Simpan file `.crt` dan `.key` di lokasi yang terdokumentasi.
* Backup certificate bersama konfigurasi NPM.
* Catat tanggal expiration dan lakukan renewal sebelum habis.

---

# Related Documents

* `Services/nginx-proxy-manager.md`
* `Runbooks/Configurations/ssl-self-signed.md`
* `Runbooks/Operations/backup-restore.md`

---

# Incident History

## 2026-06 — SSL certificate untuk `.homelab.local`

### Root Cause

Let's Encrypt tidak dapat melakukan validasi domain internal.

### Resolution

* Generate self-signed wildcard certificate.
* Import ke Nginx Proxy Manager.
* Gunakan certificate yang sama untuk seluruh service.

### Lessons Learned

Untuk Homelab yang hanya berjalan di jaringan lokal, self-signed wildcard certificate merupakan solusi sederhana dan efektif.

---

*Last updated: 2026-06-20*
