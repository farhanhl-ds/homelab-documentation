Personal homelab running on a single Proxmox VE node. Tujuan utama: self-hosted services untuk produktivitas, privacy, dan learning.

> **Current state & session log** → lihat [PROGRESS.md](./PROGRESS.md)

## Node

| Hostname | IP | Hardware |
|---|---|---|
| haytham | 192.168.100.10 | Lenovo ThinkCentre M910q Tiny |

## Architecture Overview

Gambaran keseluruhan bagaimana service saling terhubung:

```
                    Internet
                       │
               Router IndiHome
                 (100.1)
                       │
              Proxmox Host haytham
                 (100.10)
                       │
        ┌──────────────┼──────────────────┬─────────────┐
        │              │                  │             │
   LXC 101         LXC 102           LXC 103        LXC 104
  core-infra        security          database          auth
  (100.101)         (100.102)         (100.103)       (100.104)
  Pihole ◄──DNS──  Vaultwarden       PostgreSQL      Authentik
  NPM    ◄──proxy──                  Redis           (SSO/OIDC)
  Portainer                          Adminer              │
  Homepage                                               │
  Uptime Kuma                                       productivity
                                                     (100.105)
                                                      Outline
                                                     Stirling
                                                      Postiz

   VM 100
   HAOS
  (100.100)
 Home Assistant
```

---

## Quick Links (Internal)

| Service | URL | IP Langsung | Fungsi |
|---|---|---|---|
| Proxmox | https://192.168.100.10:8006 | — | Hypervisor management |
| Portainer | https://portainer.homelab.local | 192.168.100.101:9000 | Docker container management |
| Pihole | https://pihole.homelab.local | 192.168.100.101:8080 | DNS + ad blocker |
| Nginx Proxy Manager | https://npm.homelab.local | 192.168.100.101:81 | Reverse proxy + SSL |
| Homepage | https://homepage.homelab.local | 192.168.100.101:3000 | Dashboard semua service |
| Uptime Kuma | https://uptime.homelab.local | 192.168.100.101:3001 | Service monitoring |
| Vaultwarden | https://vault.homelab.local | 192.168.100.102:8080 | Password manager (self-hosted Bitwarden) |
| Adminer | https://adminer.homelab.local | 192.168.100.103:8080 | PostgreSQL web UI |
| Authentik | https://auth.homelab.local | 192.168.100.104:9000 | Identity provider / SSO |
| Outline | https://outline.homelab.local | 192.168.100.105:3000 | Knowledge base / dokumentasi |
| Stirling PDF | https://stirling.homelab.local | 192.168.100.105:8080 | PDF tools |
| Postiz | https://postiz.homelab.local | 192.168.100.105:3001 | Social media scheduler |
| Home Assistant | https://ha.homelab.local | 192.168.100.100:8123 | Smart home automation |

---

## Deployment Status & Order

| Urutan | LXC / VM | Services | Status |
|---|---|---|---|
| 1 | LXC 101 — core-infra | Portainer, Pihole, NPM, Homepage, Uptime Kuma | ✅ Done |
| 2 | LXC 102 — security | Vaultwarden | ✅ Done |
| 3 | LXC 103 — database | PostgreSQL, Redis, Adminer | ✅ Done |
| 4 | LXC 104 — auth | Authentik | ✅ Done |
| 5 | LXC 105 — productivity | Outline ✅, Stirling PDF 🔲, Postiz 🔲 | 🔄 Partial |
| 7 | VM 100 — HAOS | Home Assistant | 🔲 Pending |
| 8 | Network | Tailscale | 🔲 Pending |

**Urutan deployment dipilih berdasarkan dependency antar service:**
- **LXC 101** — NPM dan Pihole harus berjalan terlebih dahulu sebagai fondasi network
- **LXC 102** — Vaultwarden harus siap sebelum credential lain di-generate
- **LXC 103** — PostgreSQL dan Redis dibutuhkan oleh Authentik, Outline, dan Postiz
- **LXC 104** — Authentik harus tersedia sebelum service yang memerlukan SSO di-deploy

---

## Quick Recovery

Apabila homelab tidak dapat diakses setelah mati atau reboot:

1. **Periksa Proxmox** — buka `https://192.168.100.10:8006`, pastikan seluruh LXC berstatus Running
2. **Periksa LXC 103** — apabila database tidak berjalan, seluruh service akan ikut error
3. **Periksa LXC 104** — apabila Authentik tidak berjalan, login via SSO ke Outline dan Postiz akan gagal
4. **Periksa LXC 101** — apabila Pihole tidak berjalan, DNS resolution tidak akan bekerja. Gunakan kolom **IP Langsung** pada tabel Quick Links di atas sebagai akses sementara
5. **Periksa container per LXC** — masuk console LXC → `docker compose ps` dan `docker compose logs --tail=20`
6. **Restart container** — `docker compose down && docker compose up -d`

Untuk panduan troubleshooting lebih lengkap, lihat [troubleshooting.md](./troubleshooting.md).

---

*Last updated: 2026-06-17*