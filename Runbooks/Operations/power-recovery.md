# Power Recovery Procedure

Prosedur recovery homelab setelah terjadi power outage, shutdown tidak terencana, atau Proxmox host mengalami reboot.

Tujuan runbook ini adalah memastikan seluruh LXC dan service kembali berjalan sesuai dependency order.

---

## Expected Startup Order

LXC harus berjalan dengan urutan berikut:

| Order | LXC | Role | Reason |
|---|---|---|---|
| 1 | LXC 101 | Core Infrastructure | Menyediakan DNS dan reverse proxy |
| 2 | LXC 102 | Security | Vaultwarden bergantung pada DNS |
| 3 | LXC 103 | Database | PostgreSQL dan Redis untuk service lain |
| 4 | LXC 104 | Authentication | Authentik bergantung pada database |
| 5 | LXC 105 | Productivity | Outline, Postiz, dan aplikasi lain |

Konfigurasi ini diatur melalui Proxmox `onboot` startup order.

Referensi:

- `../../Infrastructure/proxmox.md`

---

# Phase 1 — Verify Proxmox Host

Login ke Proxmox host:

```bash
ssh root@192.168.100.10
```

Verifikasi host berjalan normal:

```bash
uptime
hostname
df -h
```

Pastikan:

- Tidak ada disk penuh
- Load tidak abnormal
- Hostname adalah `haytham`

---

## Phase 2 — Verify LXC Startup

Lihat status seluruh container:

```bash
pct list
```

Expected:

```
VMID STATUS
101  running
102  running
103  running
104  running
105  running
```

---

## Phase 3 — Manual Startup (Jika Auto Start Gagal)

Jalankan container sesuai dependency.

### Core Infrastructure

```bash
pct start 101
sleep 30
```

Verifikasi:

```bash
pct status 101
```

Expected:

```
status: running
```

---

### Security

```bash
pct start 102
sleep 20
```

---

### Database

```bash
pct start 103
sleep 20
```

---

### Authentication

```bash
pct start 104
sleep 10
```

---

### Productivity

```bash
pct start 105
```

---

## Phase 4 — Verify Docker Services

Masuk ke masing-masing LXC dan cek container.

### LXC 101 — Core Infrastructure

```bash
pct enter 101
docker ps
exit
```

Expected:

- pihole
- npm
- homepage
- uptime-kuma
- portainer

---

### LXC 102 — Security

```bash
pct enter 102
docker ps
exit
```

Expected:

- vaultwarden

---

### LXC 103 — Database

```bash
pct enter 103
docker ps
exit
```

Expected:

- postgres
- redis
- adminer

---

### LXC 104 — Authentication

```bash
pct enter 104
docker ps
exit
```

Expected:

- authentik-server
- authentik-worker

---

### LXC 105 — Productivity

```bash
pct enter 105
docker ps
exit
```

Expected:

- outline
- stirling-pdf (apabila sudah deploy)
- postiz (apabila sudah deploy)

---

## Phase 5 — Verify Core Infrastructure

Core infrastructure harus diperiksa terlebih dahulu karena menjadi dependency service lain.

### DNS (Pi-hole)

Test DNS resolution dari LXC lain:

```bash
pct enter 102

ping auth.homelab.local

exit
```

Expected:

```
PING auth.homelab.local (192.168.100.104)
```

---

### Reverse Proxy

Akses:

```
https://npm.homelab.local
```

Pastikan halaman Nginx Proxy Manager muncul.

---

## Phase 6 — Verify Applications

Lakukan pengecekan endpoint utama:

| Service | URL |
|---|---|
| Vaultwarden | https://vault.homelab.local |
| Adminer | https://adminer.homelab.local |
| Authentik | https://auth.homelab.local |
| Outline | https://outline.homelab.local |

Pastikan:

- HTTPS certificate valid
- Halaman dapat dibuka
- Login berhasil (jika diperlukan)

---

## Phase 7 — Check Monitoring

Akses:

```
https://uptime.homelab.local
```

Pastikan seluruh monitor berstatus:

```
UP
```

---

## Troubleshooting

### LXC tidak start

Lihat log:

```bash
journalctl -xe
```

Cek konfigurasi LXC:

```bash
pct config <CT_ID>
```

---

### Docker container tidak berjalan

Masuk ke LXC:

```bash
pct enter <CT_ID>
```

Lihat container:

```bash
docker ps -a
```

Lihat log:

```bash
docker logs <container_name>
```

Restart container:

```bash
docker restart <container_name>
```

---

### DNS tidak bekerja

Pastikan Pi-hole running:

```bash
pct enter 101
docker ps
```

Cek konfigurasi DNS LXC:

```bash
cat /etc/resolv.conf
```

---

## Recovery Complete Checklist

### Proxmox

- [ ] Host berjalan normal
- [ ] Storage tidak penuh

### LXC

- [ ] LXC 101 running
- [ ] LXC 102 running
- [ ] LXC 103 running
- [ ] LXC 104 running
- [ ] LXC 105 running

### Services

- [ ] Pi-hole berjalan
- [ ] Nginx Proxy Manager berjalan
- [ ] Vaultwarden berjalan
- [ ] PostgreSQL berjalan
- [ ] Redis berjalan
- [ ] Authentik berjalan
- [ ] Outline berjalan
- [ ] Monitoring menunjukkan status healthy

---

## Prevention

Pastikan konfigurasi auto start tetap aktif:

```bash
pct config 101 | grep startup
```

Konfigurasi startup order dapat dilihat pada:

```
Infrastructure/proxmox.md
```

---

*Last updated: 2026-06-18*