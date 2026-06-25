# Reverse Proxy Issues

Troubleshooting masalah routing request melalui Nginx Proxy Manager (NPM).

Masalah pada layer ini biasanya muncul ketika:

* DNS sudah berhasil resolve.
* Container berjalan normal.
* Service dapat diakses langsung menggunakan IP dan port.
* Tetapi akses melalui domain mengalami error.

---

# Service dapat diakses melalui IP tetapi gagal melalui domain

## Symptoms

* `http://IP:PORT` dapat dibuka.
* `https://service.homelab.local` gagal.
* Browser menampilkan error seperti:

  * 502 Bad Gateway
  * 503 Service Unavailable
  * Timeout

---

## Diagnosis

### 1. Pastikan service target berjalan

Masuk ke node tempat service berjalan:

```bash
docker ps
```

Pastikan container memiliki status:

```text
Up
```

---

### 2. Test akses langsung ke service

Contoh:

```bash
curl http://192.168.100.101:3000
```

Jika gagal:

* Masalah bukan pada NPM.
* Lanjutkan ke `docker-issues.md`.

Jika berhasil:

* Lanjutkan pemeriksaan konfigurasi NPM.

---

### 3. Periksa konfigurasi Proxy Host

Pastikan parameter berikut benar:

| Field                 | Contoh                             |
| --------------------- | ---------------------------------- |
| Domain Names          | `homepage.homelab.local`           |
| Scheme                | `http` atau `https` sesuai service |
| Forward Hostname / IP | IP node target                     |
| Forward Port          | Port internal service              |

Contoh:

```text
Domain:
homepage.homelab.local

Forward:
192.168.100.101:3000
```

---

# Pi-hole menampilkan Error 403 melalui Nginx Proxy Manager

## Symptoms

* `https://pihole.homelab.local` menampilkan halaman:

```
403 Forbidden
```

* Akses langsung:

```
http://192.168.100.101:8080/admin
```

berhasil.

---

## Root Cause

Pi-hole Admin UI berjalan pada path:

```text
/admin
```

Tetapi NPM melakukan forwarding ke root path:

```text
/
```

Akibatnya Pi-hole menolak request dan menampilkan `403 Forbidden`.

---

## Resolution

Pada Nginx Proxy Manager:

Tambahkan Custom Location:

| Field                 | Value             |
| --------------------- | ----------------- |
| Location              | `/`               |
| Forward Hostname / IP | `192.168.100.101` |
| Forward Port          | `8080`            |

Tambahkan Advanced Config:

```nginx
rewrite ^/$ /admin redirect;
```

Setelah disimpan:

```
https://pihole.homelab.local
          ↓
NPM rewrite
          ↓
/admin
          ↓
Pi-hole UI
```

---

# Application menampilkan halaman rusak atau HTML mentah

## Symptoms

* Halaman tampil tanpa CSS atau JavaScript.
* Browser hanya menampilkan source HTML.
* Login redirect atau callback tidak berjalan dengan benar.

---

## Possible Causes

Reverse proxy tidak meneruskan `X-Forwarded` headers yang dibutuhkan aplikasi.

---

## Resolution

Tambahkan konfigurasi berikut pada NPM Custom Nginx Config:

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Host $host;
```

Contoh kasus:

* Authentik menampilkan HTML mentah karena tidak mempercayai informasi dari reverse proxy.

Lihat dokumentasi lebih lanjut:

```
Troubleshooting/authentik-issues.md
```

---

# Service menghasilkan redirect URL yang salah

## Symptoms

Contoh:

```
https://service.homelab.local
```

melakukan redirect ke:

```
http://192.168.100.101:PORT
```

atau domain lain yang tidak diinginkan.

---

## Possible Causes

Aplikasi tidak mengetahui bahwa request asli datang melalui HTTPS karena header reverse proxy tidak diteruskan dengan benar.

---

## Resolution

Pastikan NPM mengirim:

```nginx
X-Forwarded-Proto
Host
X-Forwarded-For
```

dan pastikan aplikasi dikonfigurasi menggunakan URL publik yang benar.

Contoh:

```
URL=https://outline.homelab.local
```

---

# Verification Checklist

Setelah melakukan perubahan:

| Check                    | Expected Result       |
| ------------------------ | --------------------- |
| DNS domain               | Resolve ke IP NPM     |
| `docker ps`              | Container status `Up` |
| Akses `IP:PORT` langsung | Berhasil              |
| Proxy Host NPM           | Host dan port sesuai  |
| HTTPS domain             | Service tampil normal |

---

# Prevention

* Dokumentasikan semua Proxy Host yang dibuat.
* Gunakan domain publik internal yang konsisten (`*.homelab.local`).
* Selalu test service menggunakan `IP:PORT` sebelum menambahkan NPM.
* Gunakan `X-Forwarded` headers untuk aplikasi yang berada di belakang reverse proxy.
* Pisahkan masalah DNS dan reverse proxy saat troubleshooting.

---

# Related Documents

* `Services/nginx-proxy-manager.md`
* `Runbooks/Configurations/npm-proxy-host.md`
* `Runbooks/Configurations/authentik-oidc.md`
* `Troubleshooting/dns-issues.md`
* `Troubleshooting/docker-issues.md`
* `Troubleshooting/authentik-issues.md`

---

# Incident History

## 2026-06 — Pi-hole menampilkan 403 melalui domain

### Root Cause

NPM melakukan forwarding ke root `/`, sementara Pi-hole Admin UI menggunakan `/admin`.

### Resolution

Menambahkan custom location dan rewrite:

```nginx
rewrite ^/$ /admin redirect;
```

---

## 2026-06-15 — Authentik menampilkan HTML mentah

### Root Cause

Reverse proxy tidak mengirim `X-Forwarded` headers yang dibutuhkan Authentik.

### Resolution

Menambahkan:

* `X-Forwarded-Proto`
* `X-Forwarded-For`
* `Host`

pada Custom Nginx Config NPM.

---

*Last updated: 2026-06-20*
