# Health Check

Prosedur pemeriksaan kesehatan homelab untuk memastikan seluruh infrastructure, service, dan dependency berjalan normal.

Disarankan dijalankan setelah:
- Power recovery
- Update service
- Maintenance Proxmox
- Perubahan konfigurasi jaringan
- Restore dari backup

---

## Phase 1 — Verify Proxmox Host

Login ke Proxmox host:

```bash
ssh root@192.168.100.10
```

### Check Host Resource

CPU, RAM, dan uptime:

```bash
uptime
free -h
```

Storage:

```bash
df -h
```

Pastikan:
- Tidak terjadi memory pressure atau swap berlebihan
- Storage tidak penuh
- Load average dalam kondisi normal

---

## Phase 2 — Verify LXC Status

Cek seluruh container:

```bash
pct list
```

Expected:

```text
VMID Status Name
101  running core-infra
102  running security
103  running database
104  running auth
105  running productivity
```

Apabila ada LXC yang mati:

Lihat:
- `power-recovery.md`
- `Troubleshooting/*`

---

## Phase 3 — Verify Network & DNS

### Check Internet Connectivity

Dari Proxmox:

```bash
ping -c 4 1.1.1.1
```

Expected:

```text
0% packet loss
```

---

### Check DNS Resolution

Masuk ke LXC 101:

```bash
pct enter 101
```

Cek DNS upstream:

```bash
dig google.com @1.1.1.1
```

Keluar:

```bash
exit
```

Masuk ke LXC lain:

```bash
pct enter 104
```

Cek Pihole:

```bash
dig auth.homelab.local @192.168.100.101
```

Expected:
- Domain homelab resolve
- Tidak ada timeout

---

## Phase 4 — Verify Docker Containers

Masuk ke setiap LXC yang menggunakan Docker.

Contoh:

```bash
pct enter 101
```

Cek container:

```bash
docker ps
```

Pastikan:
- Semua container berstatus `Up`
- Tidak ada restart loop

Cek restart count:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

---

## Phase 5 — Verify Database Services

### PostgreSQL

Masuk ke LXC 103:

```bash
pct enter 103
```

Test koneksi:

```bash
docker exec -it postgres psql -U postgres -c "\l"
```

Pastikan:
- Database muncul
- Tidak ada connection error

---

### Redis

Test Redis:

```bash
docker exec redis redis-cli \
-a your_redis_password ping
```

Expected:

```text
PONG
```

---

## Phase 6 — Verify Web Services

Buka browser dan pastikan:

| Service | URL | Check |
|---|---|---|
| Homepage | https://homepage.homelab.local | Dashboard tampil |
| Pihole | https://pihole.homelab.local | Login berhasil |
| NPM | https://npm.homelab.local | Proxy host online |
| Portainer | https://portainer.homelab.local | Container terlihat |
| Vaultwarden | https://vault.homelab.local | Vault dapat dibuka |
| Adminer | https://adminer.homelab.local | Login berhasil |
| Authentik | https://auth.homelab.local | Login berhasil |
| Outline | https://outline.homelab.local | SSO berhasil |
| Stirling PDF | https://stirling.homelab.local | UI dapat diakses |
| Postiz | https://postiz.homelab.local | Login berhasil |

---

## Phase 7 — Verify SSL Certificate

Cek browser:

- Tidak ada warning certificate
- Domain menggunakan certificate `homelab-local`

Atau via terminal:

```bash
openssl s_client \
-connect auth.homelab.local:443 \
-servername auth.homelab.local
```

Pastikan output menunjukkan:

```text
Verify return code: 0 (ok)
```

---

## Phase 8 — Verify Tailscale

Dari Proxmox host:

```bash
tailscale status
```

Pastikan:

- Node dalam status online
- Remote access tersedia

---

## Phase 9 — Review Logs

Cek log apabila terdapat indikasi masalah.

Docker:

```bash
docker logs <container> --tail 50
```

LXC:

```bash
journalctl -xe
```

---

## Health Check Checklist

### Infrastructure

- [ ] Proxmox host normal
- [ ] CPU, RAM, dan storage sehat
- [ ] Semua LXC running
- [ ] Internet connectivity tersedia
- [ ] DNS internal berjalan
- [ ] Tailscale online

---

### Services

- [ ] Semua Docker container berjalan
- [ ] PostgreSQL normal
- [ ] Redis merespon `PONG`
- [ ] Semua web UI dapat diakses
- [ ] SSL certificate valid

---

## Important Notes

- Jangan mengabaikan restart loop walaupun service masih dapat diakses.
- Prioritaskan pengecekan database dan authentication karena menjadi dependency service lain.
- Simpan error message sebelum melakukan restart service agar root cause dapat dianalisis.

---

*Last updated: 2026-06-18*