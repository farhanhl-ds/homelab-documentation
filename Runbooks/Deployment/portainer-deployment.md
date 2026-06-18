# Portainer Deployment

Panduan deployment Portainer CE sebagai Docker management UI untuk mengelola seluruh container pada homelab.

Portainer digunakan untuk:

- Melihat status container
- Melihat logs container
- Mengelola image Docker
- Mengelola volume dan network
- Melakukan deploy stack melalui web UI

---

## Prerequisites

Pastikan:

- LXC 101 (core-infra) sudah dibuat
- Docker sudah terinstall
- Folder `/opt/stacks/` sudah tersedia

Lihat:

- `create-lxc.md`
- `docker-installation.md`

---

## Deployment Location

| | |
|---|---|
| LXC | 101 — core-infra |
| Path | `/opt/stacks/portainer/` |
| Internal Port | 9000 (HTTP), 9443 (HTTPS) |
| URL | https://portainer.homelab.local |

---

## Prepare Directory

Masuk ke LXC 101:

```bash
pct enter 101
```

Buat folder deployment:

```bash
mkdir -p /opt/stacks/portainer
cd /opt/stacks/portainer
```

---

## Create docker-compose.yml

Buat file:

```bash
nano docker-compose.yml
```

Isi:

```yaml
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
```

---

## Deploy Container

Jalankan:

```bash
docker compose up -d
```

Verifikasi:

```bash
docker compose ps
```

Expected:

```text
NAME        STATUS        PORTS
portainer   Up            0.0.0.0:9000->9000/tcp, 9443->9443/tcp
```

---

## Initial Setup

Buka browser:

```
https://192.168.100.101:9443
```

Lakukan konfigurasi pertama:

1. Create administrator account
2. Pilih **Get Started**
3. Pilih environment **Local**

Setelah selesai, Portainer akan mengelola Docker Engine pada LXC 101 melalui Docker socket.

---

## Setup NPM Proxy Host

Buat proxy host di Nginx Proxy Manager:

| Field | Value |
|---|---|
| Domain | `portainer.homelab.local` |
| Scheme | HTTPS |
| Forward Hostname | 192.168.100.101 |
| Forward Port | 9443 |
| Websockets | ✅ |
| SSL | `homelab-local` |
| Force SSL | ✅ |

> Portainer menggunakan HTTPS secara native pada port 9443, sehingga NPM melakukan HTTPS → HTTPS proxy.

---

## Post-Deploy Verification

Pastikan:

- [ ] Portainer login page dapat diakses
- [ ] Administrator account berhasil dibuat
- [ ] Environment `local` dalam status healthy
- [ ] Docker containers terlihat pada dashboard
- [ ] Portainer dapat menampilkan logs container
- [ ] Portainer dapat melihat Docker images dan volumes

---

## Important Notes

- Jangan expose port `9000` atau `9443` ke internet.
- Akses utama harus menggunakan domain:
  `https://portainer.homelab.local`
- Portainer membutuhkan akses ke `/var/run/docker.sock`, sehingga memiliki akses penuh terhadap Docker Engine.
- Backup data Portainer berada pada Docker volume `portainer_data`.

---

*Last updated: 2026-06-18*