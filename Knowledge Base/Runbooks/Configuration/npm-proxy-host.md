# Nginx Proxy Manager Proxy Host Configuration

Panduan membuat dan mengelola Proxy Host pada Nginx Proxy Manager untuk seluruh service homelab.

Nginx Proxy Manager (NPM) bertindak sebagai single entry point untuk semua HTTP/HTTPS service.

---

## Overview

Arsitektur reverse proxy:

```text
Internet / LAN Client
          |
          |
          HTTPS 443
          |
          v
Nginx Proxy Manager
192.168.100.101
          |
          |
    +-----+-----+----------------+
    |           |                |
    v           v                v
 Auth       Database          Productivity
 (104)       (103)              (105)
```

---

## Access NPM

URL:

```
https://npm.homelab.local
```

Login menggunakan administrator account.

Masuk ke:

```
Hosts
 ↓
Proxy Hosts
 ↓
Add Proxy Host
```

---

# Standard Proxy Configuration

Gunakan konfigurasi berikut untuk sebagian besar service.

## Details Tab

| Field | Value |
|---|---|
| Domain Names | service.homelab.local |
| Scheme | HTTP |
| Forward Hostname/IP | LXC IP |
| Forward Port | Service Port |
| Cache Assets | ❌ Disabled |
| Block Common Exploits | ✅ Enabled |
| Websockets Support | ✅ Enabled |

---

## SSL Tab

Gunakan konfigurasi:

| Field | Value |
|---|---|
| SSL Certificate | homelab-local |
| Force SSL | ✅ Enabled |
| HTTP/2 Support | ✅ Enabled |
| HSTS Enabled | ❌ Disabled |

> HSTS tidak direkomendasikan untuk homelab dengan self-signed certificate karena dapat menyebabkan browser menyimpan kebijakan HTTPS yang sulit dibersihkan ketika terjadi masalah certificate.

---

# Proxy Host Reference

## Core Infrastructure

| Service | Domain | Forward |
|---|---|---|
| Pihole | pihole.homelab.local | 192.168.100.101:8080 |
| Homepage | homepage.homelab.local | 192.168.100.101:3000 |
| Uptime Kuma | uptime.homelab.local | 192.168.100.101:3001 |
| NPM UI | npm.homelab.local | 192.168.100.101:81 |
| Portainer | portainer.homelab.local | 192.168.100.101:9443 (HTTPS) |

---

## Security

| Service | Domain | Forward |
|---|---|---|
| Vaultwarden | vault.homelab.local | 192.168.100.102:8080 |

---

## Database

| Service | Domain | Forward |
|---|---|---|
| Adminer | adminer.homelab.local | 192.168.100.103:8080 |

---

## Identity

| Service | Domain | Forward |
|---|---|---|
| Authentik | auth.homelab.local | 192.168.100.104:9000 |

---

## Productivity

| Service | Domain | Forward |
|---|---|---|
| Outline | outline.homelab.local | 192.168.100.105:3000 |
| Stirling PDF | stirling.homelab.local | 192.168.100.105:8080 |
| Postiz | postiz.homelab.local | 192.168.100.105:3001 |

---

## Special Cases

Beberapa service memiliki konfigurasi tambahan.

---

### Portainer

Karena Portainer menggunakan HTTPS internal:

Details:

| Field | Value |
|---|---|
| Scheme | HTTPS |
| Forward Hostname | 192.168.100.101 |
| Forward Port | 9443 |

---

### Authentik

Tambahkan pada tab:

```
Advanced
```

Custom Nginx Configuration:

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Host $host;
```

Tanpa header ini, Authentik dapat menampilkan halaman sebagai plain text atau mengalami masalah reverse proxy.

---

## Testing Proxy Host

Setelah membuat Proxy Host:

### Browser Test

Buka:

```
https://service.homelab.local
```

Pastikan:

- Tidak ada SSL warning
- Service tampil normal
- Redirect HTTP → HTTPS berjalan

---

### DNS Test

Windows:

```powershell
nslookup service.homelab.local
```

Expected:

```
Address: 192.168.100.101
```

---

### SSL Test

Linux:

```bash
openssl s_client \
-connect service.homelab.local:443 \
-servername service.homelab.local
```

Pastikan certificate:

```
CN=*.homelab.local
```

---

## Adding New Service

Ketika menambahkan service baru:

1. Deploy service
2. Pastikan service dapat diakses via IP:PORT
3. Buat DNS record (tidak perlu jika menggunakan wildcard CNAME)
4. Buat Proxy Host di NPM
5. Assign SSL certificate `homelab-local`
6. Test akses HTTPS

---

## Troubleshooting

### 502 Bad Gateway

Penyebab umum:

- Container tidak berjalan
- Forward IP salah
- Forward port salah
- Firewall memblokir koneksi

Cek:

```bash
docker ps
```

atau:

```bash
pct list
```

---

### SSL Warning

Periksa:

- Certificate `homelab-local` terpilih
- Certificate sudah di-install pada client
- DNS mengarah ke NPM

---

### Redirect Loop

Penyebab:

- Service menggunakan URL HTTP tetapi NPM menggunakan Force SSL
- Environment variable aplikasi tidak menggunakan HTTPS

Contoh:

```
URL=https://service.homelab.local
```

---

## Security Notes

- Semua akses user harus melalui NPM, bukan langsung ke port service.
- Gunakan wildcard certificate untuk konsistensi HTTPS.
- Hindari membuka port internal service ke internet.
- Simpan NPM administrator password di Vaultwarden.

---

*Last updated: 2026-06-18*