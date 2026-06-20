# Docker Issues

Troubleshooting masalah Docker Engine, Docker Compose, dan container runtime.

Masalah pada layer ini biasanya terjadi setelah network dan DNS berjalan dengan normal, tetapi service di dalam container gagal beroperasi.

---

# Docker Compose service gagal berjalan

## Symptoms

* Container tidak muncul setelah menjalankan `docker compose up -d`.
* Container langsung berhenti (`Exited`).
* Container terus melakukan restart (`Restarting`).
* Service tidak dapat diakses meskipun network normal.

---

## Diagnosis

### 1. Periksa status container

Jalankan:

```bash
docker ps -a
```

Perhatikan kolom:

* `STATUS`
* `PORTS`
* `NAMES`

Contoh masalah:

```text
Exited (1) 5 seconds ago
Restarting (1) 10 seconds ago
```

---

### 2. Periksa log container

Untuk semua service:

```bash
docker compose logs --tail=50
```

Untuk service tertentu:

```bash
docker compose logs <service-name> --tail=50
```

Cari pesan error seperti:

* Permission denied
* Connection refused
* Database connection failed
* Invalid environment variable
* Missing file atau volume

---

### 3. Validasi file Docker Compose

Periksa syntax dan hasil rendering konfigurasi:

```bash
docker compose config
```

Pastikan:

* Tidak ada syntax error.
* Environment variable terbaca dengan benar.
* Volume dan network sesuai.

---

## Resolution

Setelah penyebab diperbaiki, lakukan recreate container:

```bash
docker compose up -d --force-recreate
```

Kemudian verifikasi:

```bash
docker ps
```

Pastikan status container:

```text
Up
```

---

# Container tidak dapat mengakses internet

## Symptoms

* `docker pull` gagal.
* Container tidak dapat mengakses API eksternal.
* DNS lookup dari dalam container gagal.

---

## Diagnosis

### 1. Periksa konektivitas dasar

Dari host LXC:

```bash
ping 1.1.1.1
```

Jika gagal:

* Periksa konfigurasi network LXC.
* Lanjutkan troubleshooting ke `network-issues.md`.

---

### 2. Periksa DNS resolver

Cek konfigurasi:

```bash
cat /etc/resolv.conf
```

Contoh yang valid:

```text
nameserver 1.1.1.1
```

---

### 3. Test DNS resolution

Jalankan:

```bash
nslookup google.com
```

Jika gagal:

* Periksa konfigurasi DNS host.
* Pastikan DNS server dapat dijangkau.

---

## Resolution

Perbaiki file `/etc/resolv.conf` apabila DNS tidak valid:

```bash
echo "nameserver 1.1.1.1" > /etc/resolv.conf
```

Kemudian ulangi proses yang sebelumnya gagal.

---

# Port sudah digunakan oleh service lain

## Symptoms

* Container gagal start.
* Docker menampilkan error:

```text
bind: address already in use
```

---

## Common Case: Port 53 digunakan oleh systemd-resolved

Masalah ini umum terjadi saat deploy Pi-hole karena membutuhkan port DNS `53`.

---

## Diagnosis

Periksa service yang menggunakan port:

```bash
ss -tulpn | grep :53
```

Contoh output:

```text
systemd-resolved
```

---

## Resolution

Matikan service tersebut:

```bash
systemctl stop systemd-resolved
systemctl disable systemd-resolved
```

Atur ulang DNS resolver:

```bash
rm /etc/resolv.conf
echo "nameserver 1.1.1.1" > /etc/resolv.conf
```

Verifikasi:

```bash
cat /etc/resolv.conf
```

---

# Prevention

* Selalu jalankan `docker compose config` sebelum deployment.
* Simpan credential menggunakan `.env`, jangan hardcode di `docker-compose.yml`.
* Gunakan volume untuk data penting agar container dapat di-recreate dengan aman.
* Periksa log sebelum melakukan restart berulang kali.
* Dokumentasikan port yang digunakan setiap service.

---

# Related Documents

* `Runbooks/Deployment/docker-installation.md`
* `Runbooks/Operations/update-service.md`
* `Runbooks/Operations/backup-restore.md`
* `Services/`

---

# Incident History

## 2026-06 — Pi-hole gagal start setelah deployment

### Symptoms

Container Pi-hole gagal melakukan binding ke port DNS `53`.

### Root Cause

`systemd-resolved` sudah menggunakan port `53`.

### Resolution

* Disable `systemd-resolved`.
* Konfigurasi ulang `/etc/resolv.conf`.
* Restart deployment Pi-hole.

---

*Last updated: 2026-06-20*
