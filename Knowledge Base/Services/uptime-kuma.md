# Uptime Kuma

Uptime Kuma menyediakan service monitoring dan availability tracking untuk seluruh environment homelab.

## Service Information

| Component | Details |
|---|---|
| Service | Uptime Kuma |
| Deployment | Docker Container |
| Host Node | LXC 101 — Core Infrastructure |
| URL | https://uptime.homelab.local |
| Container Port | 3001 |

## Purpose

Uptime Kuma digunakan untuk memonitor ketersediaan dan kesehatan service dalam homelab.

Fungsi utama:

- Monitoring status internal service
- Tracking uptime dan downtime history
- Pengujian konektivitas service secara berkala
- Menyediakan dashboard status seluruh service

Uptime Kuma merupakan monitoring layer dan tidak menjadi dependency utama bagi service lain.

## Network Configuration

| Configuration | Value |
|---|---|
| Host Port Mapping | `3001 → 3001` |
| Primary Access | HTTPS melalui Nginx Proxy Manager |
| Direct Access | `http://192.168.100.101:3001` |

Akses utama menggunakan domain internal melalui Nginx Proxy Manager untuk menjaga konsistensi URL dan SSL management.

## Data Storage

Data persistent Uptime Kuma disimpan pada:
```
/opt/stacks/uptime-kuma/data/
```

Direktori ini berisi:

- Monitor configuration
- Notification settings
- Uptime history
- User account dan authentication data

Direktori data perlu disertakan dalam proses backup.

## Dependencies

### Depends On

- Docker Engine pada LXC 101
- Nginx Proxy Manager untuk akses melalui domain internal
- Network connectivity ke service yang dimonitor

### Required By

Tidak ada service yang bergantung pada Uptime Kuma.

Uptime Kuma berfungsi sebagai observability tool dan tidak berada pada jalur operasional utama service lain.

## Monitoring Strategy

Uptime Kuma digunakan untuk memonitor service penting dalam environment homelab, seperti:

- Pi-hole (DNS availability)
- Nginx Proxy Manager (reverse proxy availability)
- Authentik (authentication service)
- Database service (PostgreSQL dan Redis)
- Home Assistant
- Service internal lain yang membutuhkan availability monitoring

Daftar monitor dapat berubah seiring bertambahnya service di environment.

## Architecture Notes

### Monitoring Independence

Uptime Kuma ditempatkan pada LXC 101 bersama core infrastructure karena memiliki akses jaringan yang dekat dengan seluruh service internal.

Kegagalan Uptime Kuma tidak mempengaruhi operasional service lain karena monitoring bersifat observability, bukan dependency.

## Related Runbooks

- `Runbooks/uptime-kuma-deployment.md` — Deployment Docker container dan initial setup.
- `Runbooks/uptime-kuma-maintenance.md` — Update, backup, restore, dan troubleshooting.

---

*Last updated: 2026-06-17*