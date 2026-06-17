# Homepage

Homepage menyediakan centralized dashboard untuk mengakses dan menampilkan informasi seluruh service dalam environment homelab.

## Service Information

| Component | Details |
|---|---|
| Service | Homepage |
| Deployment | Docker Container |
| Host Node | LXC 101 — Core Infrastructure |
| URL | https://homepage.homelab.local |
| Container Port | 3000 |

## Purpose

Homepage berfungsi sebagai single dashboard untuk mengakses seluruh internal service melalui satu halaman terpusat.

Fungsi utama:

- Menampilkan shortcut ke internal service
- Menampilkan status dan informasi service melalui widgets
- Menyediakan overview environment homelab

Homepage merupakan convenience layer dan tidak menjadi dependency utama bagi service lain.

## Network Configuration

| Configuration | Value |
|---|---|
| Host Port Mapping | `3000 → 3000` |
| Primary Access | HTTPS melalui Nginx Proxy Manager |
| Direct Access | `http://192.168.100.101:3000` |

Akses utama menggunakan domain internal melalui Nginx Proxy Manager untuk menjaga konsistensi URL dan SSL management.

## Data Storage

Konfigurasi Homepage disimpan pada:
```
/opt/stacks/homepage/config/
```

Direktori ini berisi konfigurasi seperti:

- `services.yaml`
- `widgets.yaml`
- `settings.yaml`
- `bookmarks.yaml`

File konfigurasi perlu disertakan dalam proses backup.

## Dependencies

### Depends On

- Docker Engine pada LXC 101
- Nginx Proxy Manager untuk akses melalui domain internal

### Required By

Tidak ada service yang bergantung pada Homepage.

Homepage hanya berfungsi sebagai dashboard dan convenience layer.

## Architecture Notes

### Allowed Hosts Configuration

Homepage menggunakan environment variable:
```
HOMEPAGE_ALLOWED_HOSTS
```

untuk menentukan domain dan hostname yang diizinkan mengakses web interface.

Pada deployment saat ini, akses diizinkan melalui:

- `homepage.homelab.local`
- `192.168.100.101:3000`

Konfigurasi `HOMEPAGE_ALLOWED_HOSTS` dilakukan melalui Docker environment variable dan tidak dikelola melalui `settings.yaml`.

## Related Runbooks

- `Runbooks/homepage-deployment.md` — Deployment Docker container dan initial configuration.
- `Runbooks/homepage-maintenance.md` — Update, backup, restore, dan troubleshooting.

---

*Last updated: 2026-06-17*