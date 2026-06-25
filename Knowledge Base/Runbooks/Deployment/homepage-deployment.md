# Homepage Deployment

Panduan deployment Homepage sebagai dashboard utama untuk mengakses seluruh service homelab.

Homepage digunakan untuk:

- Menampilkan shortcut seluruh service
- Menampilkan status service
- Menampilkan Docker widgets
- Menjadi landing page utama homelab

---

## Prerequisites

Pastikan:

- LXC 101 (core-infra) sudah dibuat
- Docker sudah terinstall
- Folder `/opt/stacks/` tersedia

Lihat:

- `create-lxc.md`
- `docker-installation.md`

---

## Deployment Location

| | |
|---|---|
| LXC | 101 — core-infra |
| Path | `/opt/stacks/homepage/` |
| Internal Port | 3000 |
| URL | https://homepage.homelab.local |

---

## Prepare Directory

Masuk ke LXC 101:

```bash
pct enter 101
```

Buat folder deployment:

```bash
mkdir -p /opt/stacks/homepage
cd /opt/stacks/homepage
```

---

## Create Configuration Directory

Buat folder konfigurasi Homepage:

```bash
mkdir config
```

Struktur awal:

```text
/opt/stacks/homepage/
├── docker-compose.yml
└── config/
    ├── bookmarks.yaml
    ├── services.yaml
    ├── widgets.yaml
    ├── settings.yaml
    └── docker.yaml
```

> File YAML dapat dibuat kosong terlebih dahulu dan dikonfigurasi setelah Homepage berhasil berjalan.

---

## Create docker-compose.yml

Buat file:

```bash
nano docker-compose.yml
```

Isi:

```yaml
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      HOMEPAGE_ALLOWED_HOSTS: "homepage.homelab.local,192.168.100.101:3000"
    volumes:
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock

volumes: {}
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
NAME       STATUS       PORTS
homepage   Up           0.0.0.0:3000->3000/tcp
```

---

## Setup NPM Proxy Host

Buat proxy host pada Nginx Proxy Manager:

| Field | Value |
|---|---|
| Domain | `homepage.homelab.local` |
| Scheme | HTTP |
| Forward Hostname | 192.168.100.101 |
| Forward Port | 3000 |
| Websockets | ✅ |
| SSL | `homelab-local` |
| Force SSL | ✅ |

---

## Initial Configuration

Setelah Homepage dapat diakses:

### Add Services

Edit:

```bash
nano config/services.yaml
```

Tambahkan service sesuai kebutuhan:

```yaml
- Infrastructure:
    - Proxmox:
        href: https://haytham.homelab.local:8006

    - Portainer:
        href: https://portainer.homelab.local

    - Pihole:
        href: https://pihole.homelab.local
```

---

### Add Docker Integration

Edit:

```bash
nano config/docker.yaml
```

Contoh:

```yaml
my-docker:
  socket: /var/run/docker.sock
```

Hal ini memungkinkan Homepage menampilkan status container Docker.

---

## Post-Deploy Verification

Pastikan:

- [ ] Homepage dapat diakses melalui `https://homepage.homelab.local`
- [ ] Dashboard tampil normal
- [ ] Tidak muncul error `Invalid Host Header`
- [ ] Service shortcuts dapat dibuka
- [ ] Docker widgets dapat membaca container

---

## Troubleshooting

### Error: Invalid Host Header

Penyebab:

Homepage tidak mengenali hostname yang digunakan.

Solusi:

Pastikan environment variable berikut terdapat pada `docker-compose.yml`:

```yaml
environment:
  HOMEPAGE_ALLOWED_HOSTS: "homepage.homelab.local,192.168.100.101:3000"
```

> Konfigurasi ini harus dilakukan melalui environment variable. Menambahkan hostname pada `settings.yaml` tidak akan mengatasi masalah.

---

## Important Notes

- Homepage tidak menyimpan data penting, sehingga risiko update relatif rendah.
- Docker socket diberikan agar Homepage dapat membaca status container.
- Akses utama menggunakan domain:
  `https://homepage.homelab.local`
- Semua konfigurasi dashboard tersimpan di:
  `/opt/stacks/homepage/config/`

---

*Last updated: 2026-06-18*