# Troubleshooting Guide

Panduan troubleshooting untuk seluruh environment Homelab.

Dokumen ini berisi daftar kategori masalah berdasarkan layer arsitektur.  
Mulai dari masalah level infrastructure hingga application.

---

# Troubleshooting Flow

Gunakan urutan berikut untuk mempersempit sumber masalah:

```text
Hardware / Hypervisor
        ↓
Infrastructure Issues
        ↓
Network Connectivity
        ↓
DNS Resolution
        ↓
Container Runtime
        ↓
Reverse Proxy & HTTPS
        ↓
Authentication / Identity
        ↓
Application
```

---

# Categories

## Infrastructure Issues

Masalah pada layer hardware, BIOS, dan Proxmox.

Contoh:

- Proxmox gagal boot setelah instalasi
- Boot order salah
- Secure Boot aktif
- Intel VT-x / VT-d belum aktif

File:

```text
Troubleshooting/infrastructure-issues.md
```

---

## Network Issues

Masalah konektivitas antar perangkat dalam jaringan.

Contoh:

- LXC tidak dapat melakukan ping ke gateway
- Device tidak dapat menjangkau service lain
- IP address atau gateway salah

File:

```text
Troubleshooting/network-issues.md
```

---

## DNS Issues

Masalah resolusi domain internal.

Contoh:

- Domain `*.homelab.local` tidak dapat di-resolve
- Windows menggunakan DNS IPv6 dari router
- Pi-hole tidak menerima DNS request dari LAN

File:

```text
Troubleshooting/dns-issues.md
```

---

## Docker Issues

Masalah pada Docker Engine dan container runtime.

Contoh:

- Container tidak dapat mengakses internet
- Port sudah digunakan oleh service lain
- Docker Compose gagal menjalankan service

File:

```text
Troubleshooting/docker-issues.md
```

---

## Reverse Proxy Issues

Masalah routing request melalui Nginx Proxy Manager.

Contoh:

- Service menampilkan 403 atau 502 melalui domain
- Path aplikasi tidak sesuai
- `X-Forwarded` header tidak diteruskan dengan benar

File:

```text
Troubleshooting/reverse-proxy-issues.md
```

---

## Certificate Issues

Masalah SSL/TLS certificate.

Contoh:

- Let's Encrypt tidak dapat digunakan untuk domain internal
- Browser menampilkan warning certificate
- Certificate tidak sesuai dengan domain

File:

```text
Troubleshooting/certificate-issues.md
```

---

## Authentication Issues

Masalah pada Identity Provider dan SSO.

Contoh:

- Authentik gagal start
- Login loop
- Redis connection error
- OIDC configuration error

File:

```text
Troubleshooting/authentik-issues.md
```

---

## Application Issues

Masalah spesifik aplikasi.

Saat ini tersedia:

### Outline Issues

Contoh:

- OIDC redirect gagal
- Internal DNS tidak dapat di-resolve
- Database connection error
- Secure cookie error

File:

```text
Troubleshooting/outline-issues.md
```

---

# General Troubleshooting Checklist

Sebelum masuk ke kategori spesifik, lakukan pengecekan dasar berikut.

## 1. Periksa status LXC

Dari Proxmox host:

```bash
pct list
```

Pastikan status:

```text
running
```

---

## 2. Periksa status Docker container

Masuk ke LXC terkait:

```bash
docker ps -a
```

Perhatikan:

- Container dengan status `Exited`
- Restart loop
- Port yang tidak terbuka

---

## 3. Periksa log service

Untuk Docker Compose:

```bash
docker compose logs --tail=50
```

Atau service tertentu:

```bash
docker compose logs <service-name> --tail=50
```

---

## 4. Periksa konektivitas jaringan

Cek koneksi ke gateway:

```bash
ping 192.168.100.1
```

Cek DNS:

```bash
nslookup google.com
```

---

## 5. Periksa penggunaan resource

CPU dan memory:

```bash
top
```

Storage:

```bash
df -h
```

---

# Incident History

Dokumentasi masalah besar yang pernah terjadi.

| Date | Incident | Root Cause |
|---|---|---|
| 2025-06 | Proxmox gagal boot setelah instalasi | Boot order salah dan Secure Boot aktif |
| 2026-06-14 | Domain `.homelab.local` tidak dapat di-resolve | Windows IPv6 lebih prioritas dan Pi-hole `listeningMode` masih `LOCAL` |
| 2026-06-15 | Outline SSO gagal | Internal DNS, self-signed TLS, dan OIDC endpoint tidak sesuai |

---

# Related Documents

- `Runbooks/Operations/health-check.md`
- `Runbooks/Operations/power-recovery.md`
- `Runbooks/Operations/backup-restore.md`
- `Runbooks/Operations/update-service.md`

---

*Last updated: 2026-06-20*