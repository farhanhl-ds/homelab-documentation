# Portainer

Portainer menyediakan web-based management interface untuk Docker environment yang berjalan pada homelab.

## Service Information

| Component      | Details                         |
| -------------- | ------------------------------- |
| Service        | Portainer Community Edition     |
| Deployment     | Docker Container                |
| Host Node      | LXC 101 — Core Infrastructure   |
| URL            | https://portainer.homelab.local |
| Container Port | 9443                            |
| HTTP Port      | 9000 (legacy/optional)          |

## Purpose

Portainer digunakan untuk mempermudah administrasi Docker melalui graphical interface.

Fungsi utama:

* Monitoring status container
* Melihat logs container
* Restart dan lifecycle management container
* Management Docker volume dan network
* Management Docker stack

Portainer digunakan sebagai management layer dan bukan dependency utama bagi service lain.

## Network Configuration

| Configuration     | Value                             |
| ----------------- | --------------------------------- |
| Host Port Mapping | `9443 → 9443`, `9000 → 9000`      |
| Primary Access    | HTTPS melalui Nginx Proxy Manager |
| Direct Access     | `https://192.168.100.101:9443`    |

Port `9443` merupakan endpoint utama untuk Portainer menggunakan HTTPS.

## Data Storage

Portainer menyimpan data persistent menggunakan Docker volume:

```
portainer_data
```

Volume ini berisi:

* User account dan authentication data
* Environment configuration
* Docker endpoint configuration
* Application settings

Data volume perlu disertakan dalam proses backup.

## Dependencies

### Depends On

* Docker Engine pada LXC 101
* Docker socket (`/var/run/docker.sock`) untuk mengelola Docker daemon
* Nginx Proxy Manager untuk akses melalui domain internal

### Required By

Tidak ada service lain yang bergantung pada Portainer.

Portainer hanya merupakan administrative tool.

## Architecture Notes

### Docker Socket Access

Portainer diberikan akses ke:

```
/var/run/docker.sock
```

Akses ini memberikan kontrol penuh terhadap Docker daemon.

Konfigurasi ini dapat diterima karena Portainer hanya tersedia pada jaringan internal yang trusted dan digunakan untuk administrasi homelab.

### Management Access

Walaupun Portainer menyediakan web interface secara langsung melalui port `9443`, akses utama dilakukan melalui:

```
https://portainer.homelab.local
```

melalui Nginx Proxy Manager untuk menjaga konsistensi akses menggunakan domain internal.

## Related Runbooks

* `Runbooks/portainer-deployment.md` — Deployment Docker container dan initial setup.
* `Runbooks/portainer-maintenance.md` — Update, backup, restore, dan troubleshooting.

---

*Last updated: 2026-06-17*
