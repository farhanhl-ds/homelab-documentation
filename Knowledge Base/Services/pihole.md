# Pi-hole

Pi-hole berfungsi sebagai DNS resolver utama dan ad-blocking service untuk seluruh environment homelab.

## Service Information

| Component   | Details                       |
| ----------- | ----------------------------- |
| Service     | Pi-hole                       |
| Version     | v6                            |
| Deployment  | Docker Container              |
| Host Node   | LXC 101 — Core Infrastructure |
| URL         | https://pihole.homelab.local  |
| Web UI Port | 8080 (internal)               |

## Purpose

Pi-hole menyediakan layanan DNS internal untuk:

* Resolusi domain `*.homelab.local`
* DNS filtering dan ad blocking
* Central DNS management untuk seluruh LXC, VM, dan client dalam jaringan

## Network Configuration

| Configuration     | Value                        |
| ----------------- | ---------------------------- |
| Container Port    | `53/tcp`, `53/udp`, `80/tcp` |
| Host Port Mapping | `53 → 53`, `8080 → 80`       |
| Upstream DNS      | `1.1.1.1`, `8.8.8.8`         |
| Listening Mode    | `ALL`                        |

Port web UI dipetakan ke `8080` untuk menghindari konflik dengan Nginx Proxy Manager yang menggunakan port `80` dan `443` pada host LXC.

Listening mode menggunakan `ALL` agar Pi-hole dapat menerima query DNS dari seluruh interface jaringan internal.

## Data Storage

Docker volume dan konfigurasi Pi-hole disimpan pada:

```
/opt/stacks/pihole/
├── compose.yaml
├── etc-pihole/
└── etc-dnsmasq.d/
```

Direktori `etc-pihole` dan `etc-dnsmasq.d` merupakan data persistent yang harus termasuk dalam proses backup.

## Dependencies

### Depends On

* Docker Engine pada LXC 101
* External upstream DNS (`1.1.1.1` dan `8.8.8.8`) untuk resolusi internet

### Required By

* LXC 102 — Security
* LXC 103 — Database
* LXC 104 — Authentication
* LXC 105 — Productivity
* VM 100 — Home Assistant OS
* Seluruh client yang menggunakan Pi-hole sebagai DNS server

## Architecture Notes

### Circular Dependency Prevention

LXC 101 tidak menggunakan Pi-hole sebagai DNS resolver.

Karena Pi-hole berjalan pada LXC 101, penggunaan DNS lokal (`192.168.100.101`) akan menyebabkan circular dependency. Apabila Pi-hole gagal berjalan, LXC 101 akan kehilangan kemampuan DNS resolution.

Oleh karena itu, LXC 101 menggunakan external DNS (`1.1.1.1`) sebagaimana dijelaskan pada `Infrastructure/network.md`.

### Security Consideration

Pi-hole dikonfigurasi dengan `DNSMASQ_LISTENING=all` dan `listeningMode=ALL` sehingga service dapat menerima DNS query dari seluruh interface jaringan internal.

Konfigurasi ini dianggap acceptable karena Pi-hole hanya terekspos pada trusted local network dan tidak dipublikasikan ke internet.

## Related Runbooks

* `Runbooks/pihole-deployment.md` — Deployment Docker container dan initial configuration.
* `Runbooks/pihole-maintenance.md` — Update, backup, restore, dan troubleshooting.

---

*Last updated: 2026-06-17*
