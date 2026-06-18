# Uptime Kuma Deployment

Panduan deployment Uptime Kuma sebagai availability monitoring untuk seluruh service homelab.

Uptime Kuma digunakan untuk:

- Monitoring HTTP/HTTPS service
- Monitoring TCP port
- Monitoring ping (ICMP)
- Mengirim notifikasi ketika service down
- Menampilkan historical uptime

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
| Path | `/opt/stacks/uptime-kuma/` |
| Internal Port | 3001 |
| URL | https://uptime.homelab.local |

---

## Prepare Directory

Masuk ke LXC 101:

```bash
pct enter 101
```

Buat folder deployment:

```bash
mkdir -p /opt/stacks/uptime-kuma
cd /opt/stacks/uptime-kuma
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
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: unless-stopped
    ports:
      - "3001:3001"
    volumes:
      - ./data:/app/data

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
NAME          STATUS       PORTS
uptime-kuma   Up           0.0.0.0:3001->3001/tcp
```

---

## Initial Setup

Buka browser:

```
http://192.168.100.101:3001
```

Lakukan konfigurasi pertama:

1. Buat administrator username
2. Buat password yang kuat
3. Simpan credential ke Vaultwarden

Setelah login, Uptime Kuma siap digunakan.

---

## Setup NPM Proxy Host

Buat proxy host pada Nginx Proxy Manager:

| Field | Value |
|---|---|
| Domain | `uptime.homelab.local` |
| Scheme | HTTP |
| Forward Hostname | 192.168.100.101 |
| Forward Port | 3001 |
| Websockets | ✅ |
| SSL | `homelab-local` |
| Force SSL | ✅ |

---

## Create Initial Monitors

Disarankan membuat monitor berikut sebagai baseline.

### Infrastructure

| Name | Type | Target |
|---|---|---|
| Proxmox | Ping | 192.168.100.10 |
| Router | Ping | 192.168.100.1 |
| Core Infrastructure | Ping | 192.168.100.101 |
| Database | Ping | 192.168.100.103 |
| Authentication | Ping | 192.168.100.104 |
| Productivity | Ping | 192.168.100.105 |

---

### Core Services

| Service | Type | Target |
|---|---|---|
| Pihole | HTTP(s) | https://pihole.homelab.local |
| NPM | HTTP(s) | https://npm.homelab.local |
| Portainer | HTTP(s) | https://portainer.homelab.local |
| Homepage | HTTP(s) | https://homepage.homelab.local |

---

### Critical Dependencies

| Service | Type | Target |
|---|---|---|
| PostgreSQL | TCP | 192.168.100.103:5432 |
| Redis | TCP | 192.168.100.103:6379 |
| Authentik | HTTP(s) | https://auth.homelab.local |

---

### Applications

| Service | Type | Target |
|---|---|---|
| Vaultwarden | HTTP(s) | https://vault.homelab.local |
| Outline | HTTP(s) | https://outline.homelab.local |
| Stirling PDF | HTTP(s) | https://stirling.homelab.local |
| Postiz | HTTP(s) | https://postiz.homelab.local |

---

## Configure Notifications (Optional)

Uptime Kuma mendukung berbagai notification provider:

- Telegram
- Discord
- Email SMTP
- Slack
- Webhook

Untuk homelab pribadi, Telegram biasanya menjadi pilihan paling sederhana.

---

## Data Persistence

Semua data Uptime Kuma disimpan pada:

```
/opt/stacks/uptime-kuma/data/
```

Folder tersebut berisi:

- User account
- Password hash
- Monitor configuration
- Uptime history
- Notification settings

Pastikan folder ini masuk ke strategi backup.

---

## Post-Deploy Verification

Pastikan:

- [ ] Uptime Kuma dapat diakses melalui `https://uptime.homelab.local`
- [ ] Administrator account berhasil dibuat
- [ ] Semua monitor baseline berhasil dibuat
- [ ] Monitor menunjukkan status normal
- [ ] Notification test berhasil (apabila digunakan)
- [ ] Data directory masuk ke backup policy

---

## Important Notes

- Uptime Kuma hanya melakukan availability monitoring, bukan performance monitoring.
- Service yang statusnya "UP" belum tentu bekerja dengan benar.
- Gunakan `health-check.md` untuk validasi menyeluruh setelah outage atau maintenance.
- Jangan menghapus folder `data/` karena seluruh konfigurasi monitoring tersimpan di sana.

---

*Last updated: 2026-06-18*