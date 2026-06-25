# Power Recovery Procedure

Prosedur recovery homelab setelah terjadi power outage, shutdown tidak terencana, atau Proxmox host mengalami reboot.

Tujuan runbook ini adalah memastikan seluruh LXC dan service kembali berjalan sesuai dependency order.

---

## Related Documents

- `Infrastructure/proxmox.md`
- `Runbooks/disaster-recovery.md`

---

## Expected Startup Order

LXC harus berjalan dengan urutan berikut:

| Order | LXC | Role | Reason |
|---|---|---|---|
| 1 | LXC 101 | Core Infrastructure | Menyediakan DNS dan reverse proxy |
| 2 | LXC 102 | Security | Vaultwarden bergantung pada DNS |
| 3 | LXC 103 | Database | PostgreSQL dan Redis untuk service lain |
| 4 | LXC 104 | Authentication | Authentik bergantung pada database |
| 5 | LXC 105 | Productivity | Outline, Stirling PDF, Postiz, dan aplikasi lain |

Konfigurasi ini diatur melalui Proxmox `onboot` startup order.

---

# Phase 1 — Verify Proxmox Host

Login ke Proxmox host:

```bash
ssh root@192.168.100.10
```

Verifikasi kondisi host:

```bash
uptime
hostname
df -h
systemctl status pve-cluster
```

Pastikan:

- Tidak ada disk penuh
- Load tidak abnormal
- Hostname adalah `haytham`
- Service `pve-cluster` berjalan normal

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

Verifikasi konfigurasi auto start:

```bash
for id in 101 102 103 104 105; do
  echo "LXC $id"
  pct config $id | grep -E "onboot|startup"
done
```

Expected:

```text
onboot: 1
startup: order=x,up=x
```

---

## Phase 3 — Manual Startup (Jika Auto Start Gagal)

Jalankan container sesuai dependency order.

### LXC 101 — Core Infrastructure

```bash
pct start 101
sleep 30
```

Verifikasi:

```bash
pct status 101
```

Expected:

```text
status: running
```

---

### LXC 102 — Security

```bash
pct start 102
sleep 20
```

---

### LXC 103 — Database

```bash
pct start 103
sleep 20
```

---

### LXC 104 — Authentication

```bash
pct start 104
sleep 10
```

---

### LXC 105 — Productivity

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
- nginx-proxy-manager
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

Masuk ke LXC lain untuk melakukan DNS test:

```bash
pct enter 102
```

Test resolusi domain:

```bash
nslookup auth.homelab.local 192.168.100.101
```

Expected:

```text
Name: auth.homelab.local
Address: 192.168.100.104
```

Tambahan test connectivity:

```bash
ping auth.homelab.local
```

Keluar dari LXC:

```bash
exit
```

---

### Reverse Proxy (Nginx Proxy Manager)

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

```text
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

Lihat seluruh container:

```bash
docker ps -a
```

Lihat log container:

```bash
docker logs <container_name>
```

Restart container:

```bash
docker restart <container_name>
```

---

### DNS tidak bekerja

Pastikan Pi-hole berjalan:

```bash
pct enter 101
docker ps
exit
```

Cek DNS resolver pada LXC:

```bash
cat /etc/resolv.conf
```

Pastikan DNS mengarah ke:

```text
192.168.100.101
```

---

## Recovery Complete Checklist

### Proxmox Host

- [ ] Host berjalan normal
- [ ] Storage tidak penuh
- [ ] pve-cluster berjalan normal

---

### LXC

- [ ] LXC 101 running
- [ ] LXC 102 running
- [ ] LXC 103 running
- [ ] LXC 104 running
- [ ] LXC 105 running

---

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
for id in 101 102 103 104 105; do
  pct config $id | grep -E "onboot|startup"
done
```

Konfigurasi startup order lebih detail dapat dilihat pada:

- `Infrastructure/proxmox.md`

---

*Last updated: 2026-06-19*