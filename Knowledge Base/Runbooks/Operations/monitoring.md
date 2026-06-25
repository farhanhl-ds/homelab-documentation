# Monitoring

Prosedur monitoring homelab untuk memastikan seluruh infrastructure dan service tetap berjalan normal.

Monitoring saat ini menggunakan:

- Uptime Kuma untuk availability monitoring
- Proxmox dashboard untuk resource monitoring
- Docker logs untuk troubleshooting

---

## Monitoring Architecture

```
                    Uptime Kuma
                         |
                         |
       +-----------------+-----------------+
       |                 |                 |
    HTTP/HTTPS          TCP              ICMP
       |                 |                 |
       v                 v                 v

 Homepage         PostgreSQL            Proxmox
 Authentik        Redis                 LXC Network
 Outline          SSH
 Vaultwarden
 NPM
 Pihole
```

---

## Uptime Kuma

### Location

| | |
|---|---|
| LXC | 101 — core-infra |
| URL | https://uptime.homelab.local |
| Port | 3001 |
| Docker Path | `/opt/stacks/uptime-kuma/` |

---

## Recommended Monitors

### Infrastructure

| Name | Type | Target | Interval |
|---|---|---|---|
| Proxmox Host | Ping | 192.168.100.10 | 60s |
| Router | Ping | 192.168.100.1 | 60s |
| Core Infrastructure | Ping | 192.168.100.101 | 60s |
| Database LXC | Ping | 192.168.100.103 | 60s |
| Auth LXC | Ping | 192.168.100.104 | 60s |
| Productivity LXC | Ping | 192.168.100.105 | 60s |

---

### Web Applications

Gunakan monitor **HTTP(s)**.

| Service | URL | Expected |
|---|---|---|
| Homepage | https://homepage.homelab.local | 200 OK |
| Pihole | https://pihole.homelab.local | 200 OK |
| NPM | https://npm.homelab.local | 200 OK |
| Portainer | https://portainer.homelab.local | 200 OK |
| Vaultwarden | https://vault.homelab.local | 200 OK |
| Adminer | https://adminer.homelab.local | 200 OK |
| Authentik | https://auth.homelab.local | 200 OK |
| Outline | https://outline.homelab.local | 200 OK |
| Stirling PDF | https://stirling.homelab.local | 200 OK |
| Postiz | https://postiz.homelab.local | 200 OK |

---

### Database Services

Gunakan monitor TCP.

| Service | Host | Port |
|---|---|---|
| PostgreSQL | 192.168.100.103 | 5432 |
| Redis | 192.168.100.103 | 6379 |

> TCP monitoring hanya memastikan port terbuka, bukan memastikan query database berhasil. Gunakan `health-check.md` untuk validasi lebih mendalam.

---

### Remote Access

| Service | Type | Target |
|---|---|---|
| Tailscale SSH | TCP | 100.x.x.x:22 |

> Ganti IP Tailscale sesuai IP yang diberikan pada node Proxmox.

---

## Notification Strategy

Disarankan menggunakan notifikasi untuk service penting.

### Critical

Harus mengirim alert:

- Proxmox host offline
- LXC 101 (DNS + Reverse Proxy) offline
- PostgreSQL offline
- Authentik offline

---

### Warning

Notifikasi tidak terlalu mendesak:

- Homepage offline
- Uptime Kuma offline
- Stirling PDF offline
- Postiz offline

---

## Proxmox Resource Monitoring

Buka:

```
https://192.168.100.10:8006
```

Periksa secara berkala:

### CPU

Target normal:

- Idle: < 10%
- Peak: sesuai workload

---

### Memory

Dengan RAM 8GB saat ini:

- Usage normal: 70–85%
- Warning: >90%
- Critical: swap aktif terus-menerus

---

### Storage

Threshold:

| Usage | Status |
|---|---|
| < 80% | Normal |
| 80–90% | Warning |
| > 90% | Critical |

---

## Docker Monitoring

Masuk ke LXC terkait:

```bash
pct enter <CT_ID>
```

Cek container:

```bash
docker ps
```

Cek restart:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

Perhatikan:

- Restart loop
- Container Exit
- High memory usage

---

## Daily Quick Check

Waktu yang dibutuhkan: ± 2 menit.

Checklist:

- [ ] Uptime Kuma semua monitor hijau
- [ ] Tidak ada service offline
- [ ] Proxmox tidak menggunakan swap berlebihan
- [ ] Storage tidak mendekati penuh
- [ ] Tidak ada container restart berulang

---

## Future Improvement

Apabila homelab berkembang, pertimbangkan menambahkan:

### Prometheus + Grafana

Untuk mendapatkan:

- Historical CPU/RAM usage
- Disk utilization trend
- Container metrics
- Network throughput
- Custom dashboard

### Alerting

Integrasi yang dapat ditambahkan:

- Telegram
- Discord
- Email SMTP

---

## Important Notes

- Uptime Kuma cukup untuk homelab skala kecil hingga menengah.
- Jangan menambahkan monitoring stack yang kompleks sebelum benar-benar diperlukan.
- Availability monitoring tidak menggantikan backup.
- Service yang terlihat online belum tentu berfungsi dengan benar, gunakan `health-check.md` untuk validasi menyeluruh.

---

*Last updated: 2026-06-18*