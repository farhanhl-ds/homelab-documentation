# Nginx Proxy Manager

Nginx Proxy Manager (NPM) berfungsi sebagai reverse proxy dan SSL termination layer untuk seluruh web service dalam environment homelab.

## Service Information

| Component         | Details                       |
| ----------------- | ----------------------------- |
| Service           | Nginx Proxy Manager           |
| Deployment        | Docker Container              |
| Host Node         | LXC 101 — Core Infrastructure |
| URL               | https://npm.homelab.local     |
| Admin Port        | 81                            |
| Public HTTP Port  | 80                            |
| Public HTTPS Port | 443                           |

## Purpose

NPM menyediakan centralized access management untuk seluruh internal web service melalui domain `*.homelab.local`.

Fungsi utama:

* Reverse proxy dari domain ke internal service
* SSL certificate management
* HTTPS enforcement melalui Force SSL
* Centralized entry point untuk web application internal

Contoh alur akses:

```
Client
  │
  ▼
https://service.homelab.local
  │
  ▼
Nginx Proxy Manager (192.168.100.101)
  │
  ▼
Internal Service
```

## Network Configuration

| Configuration     | Value                                          |
| ----------------- | ---------------------------------------------- |
| Host Port Binding | `80/tcp`, `443/tcp`, `81/tcp`                  |
| HTTP Traffic      | Port `80` digunakan untuk redirect ke HTTPS    |
| HTTPS Traffic     | Port `443` digunakan untuk seluruh web service |
| Management UI     | Port `81` melalui `npm.homelab.local`          |

Karena NPM menggunakan port `80` dan `443` pada host LXC, service lain yang membutuhkan web interface tidak boleh menggunakan kedua port tersebut secara langsung.

Contoh:

* Pi-hole menggunakan `8080 → 80`
* Homepage menggunakan `3000 → 3000`
* Uptime Kuma menggunakan `3001 → 3001`

## SSL Configuration

| Configuration    | Value                            |
| ---------------- | -------------------------------- |
| Certificate Type | Self-signed wildcard certificate |
| Domain Coverage  | `*.homelab.local`                |
| Certificate Name | `homelab-local`                  |

Wildcard certificate di-import ke NPM dan digunakan oleh seluruh proxy host.

Root certificate telah di-install pada trusted client device sehingga browser dapat mempercayai certificate internal.

Detail pembuatan dan deployment certificate dijelaskan pada `Infrastructure/network.md` dan `Runbooks/ssl-self-signed.md`.

## Proxy Host Design

Setiap web service yang diakses melalui domain internal memiliki konfigurasi proxy host tersendiri di NPM.

Contoh:

| Domain                    | Target                 |
| ------------------------- | ---------------------- |
| `pihole.homelab.local`    | `192.168.100.101:8080` |
| `homepage.homelab.local`  | `192.168.100.101:3000` |
| `uptime.homelab.local`    | `192.168.100.101:3001` |
| `portainer.homelab.local` | `192.168.100.101:9443` |

Setiap proxy host menggunakan:

* SSL certificate `homelab-local`
* Force SSL enabled
* HTTP/2 support enabled

## Dependencies

### Depends On

* Docker Engine pada LXC 101
* DNS resolver (Pi-hole) untuk resolusi domain `*.homelab.local`
* SSL certificate `homelab-local`

### Required By

* Seluruh internal web service yang diakses melalui domain `*.homelab.local`
* Client device yang membutuhkan akses HTTPS ke service internal

## Architecture Notes

### Reverse Proxy Centralization

Seluruh web service diakses melalui NPM sebagai single entry point.

Pendekatan ini memberikan beberapa keuntungan:

* Konsistensi URL menggunakan domain internal
* Centralized SSL management
* Tidak perlu mengingat IP address dan port setiap service
* Mempermudah penambahan service baru

### Local-Only Exposure

NPM hanya tersedia di jaringan internal dan tidak melakukan port forwarding ke internet.

Remote access ke service internal dilakukan melalui Tailscale subnet router yang berjalan pada Proxmox host.

## Related Runbooks

* `Runbooks/nginx-proxy-manager-deployment.md` — Deployment Docker container dan initial setup.
* `Runbooks/ssl-self-signed.md` — Generate, import, dan renewal certificate.
* `Runbooks/proxy-host-management.md` — Menambah, mengubah, dan menghapus proxy host.

---

*Last updated: 2026-06-17*
