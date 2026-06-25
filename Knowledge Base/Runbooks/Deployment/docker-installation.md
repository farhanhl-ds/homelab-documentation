# Docker Installation

Panduan instalasi Docker Engine dan Docker Compose plugin pada LXC Ubuntu 24.04 LTS.

Docker digunakan sebagai runtime utama untuk menjalankan seluruh service homelab.

---

## Prerequisites

Pastikan LXC sudah dibuat dengan konfigurasi:

- Ubuntu 24.04 LTS
- Unprivileged container enabled
- Nesting enabled
- Network dan DNS berfungsi

Untuk langkah pembuatan LXC, lihat:

- `create-lxc.md`

---

## 1. Update Operating System

Jalankan update package terlebih dahulu.

```bash
apt update
apt upgrade -y
apt autoremove -y
```

---

## 2. Install Required Package

Install package yang dibutuhkan untuk download Docker.

```bash
apt install -y curl ca-certificates
```

Verifikasi:

```bash
curl --version
```

---

## 3. Install Docker Engine

Install Docker menggunakan official installation script:

```bash
curl -fsSL https://get.docker.com | sh
```

Verifikasi instalasi:

```bash
docker --version
```

Contoh output:

```
Docker version 28.x.x, build xxxxx
```

---

## 4. Verify Docker Service

Pastikan Docker service berjalan.

```bash
systemctl status docker
```

Expected:

```
Active: active (running)
```

Alternatif verifikasi:

```bash
docker info
```

---

## 5. Verify Docker Compose Plugin

Docker Compose v2 sudah termasuk dalam instalasi Docker modern.

Verifikasi:

```bash
docker compose version
```

Contoh:

```
Docker Compose version v2.x.x
```

---

## 6. Create Stack Directory

Seluruh docker-compose dan data service disimpan di `/opt/stacks`.

Buat direktori utama:

```bash
mkdir -p /opt/stacks
```

Verifikasi:

```bash
ls -la /opt
```

Expected:

```
stacks/
```

---

## 7. Configure Docker Auto Start

Pastikan Docker otomatis berjalan saat LXC reboot.

Verifikasi:

```bash
systemctl is-enabled docker
```

Expected:

```
enabled
```

Apabila belum aktif:

```bash
systemctl enable docker
```

---

## 8. Test Docker Container

Jalankan test container:

```bash
docker run --rm hello-world
```

Expected output:

```
Hello from Docker!
```

Container akan otomatis dihapus setelah selesai.

---

## 9. Check Docker Storage

Verifikasi lokasi Docker data:

```bash
docker info | grep "Docker Root Dir"
```

Expected:

```
Docker Root Dir: /var/lib/docker
```

---

## 10. Recommended Directory Convention

Gunakan struktur berikut untuk setiap service:

```
/opt/stacks/
├── service-name/
│   ├── docker-compose.yml
│   ├── .env
│   └── data/
```

Contoh:

```
/opt/stacks/vaultwarden/
├── docker-compose.yml
└── data/
```

---

## Docker Compose Convention

Standar yang digunakan di seluruh homelab:

### Container Name

Gunakan nama yang sederhana:

```yaml
container_name: postgres
```

Bukan:

```yaml
container_name: homelab-postgresql-container
```

---

### Restart Policy

Gunakan:

```yaml
restart: unless-stopped
```

Agar container otomatis kembali berjalan setelah LXC reboot.

---

### Secret Management

Jangan menyimpan password secara langsung di `docker-compose.yml`.

Gunakan `.env`:

Contoh:

```env
POSTGRES_PASSWORD=your_password
```

Kemudian panggil:

```yaml
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

Seluruh credential harus disimpan di Vaultwarden.

---

## Troubleshooting

### Docker command not found

Verifikasi instalasi:

```bash
which docker
```

Apabila kosong, ulangi proses instalasi Docker.

---

### Cannot connect to Docker daemon

Periksa service:

```bash
systemctl status docker
```

Restart service:

```bash
systemctl restart docker
```

---

### Docker container gagal start di LXC

Verifikasi fitur nesting:

Di Proxmox host:

```bash
pct config <CT_ID>
```

Pastikan terdapat:

```
features: nesting=1
```

Apabila belum:

```bash
pct set <CT_ID> -features nesting=1
```

Kemudian restart LXC:

```bash
pct reboot <CT_ID>
```

---

## Post-Installation Checklist

- [ ] Operating system di-update
- [ ] Docker Engine berhasil terinstall
- [ ] Docker daemon running
- [ ] Docker Compose plugin tersedia
- [ ] Directory `/opt/stacks` dibuat
- [ ] Docker auto-start enabled
- [ ] `hello-world` container berhasil dijalankan

---

## Next Step

Setelah Docker siap, lanjutkan deployment service sesuai role LXC:

| LXC | Service |
|---|---|
| 101 | Pi-hole, Nginx Proxy Manager, Homepage, Uptime Kuma, Portainer |
| 102 | Vaultwarden |
| 103 | PostgreSQL, Redis, Adminer |
| 104 | Authentik |
| 105 | Outline, Stirling PDF, Postiz |

Lihat runbook deployment masing-masing service.

---

*Last updated: 2026-06-18*