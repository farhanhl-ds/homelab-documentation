# Create LXC Container

Panduan membuat Linux Container (LXC) di Proxmox dengan standar konfigurasi homelab.

LXC digunakan sebagai host untuk menjalankan Docker dan service aplikasi.

---

## Prerequisites

Pastikan Proxmox host sudah berjalan dengan konfigurasi:

- Hostname: `haytham.homelab.local`
- IP Address: `192.168.100.10`
- Network bridge: `vmbr0`
- Storage: `local-lvm`

Referensi:

- `../../Infrastructure/proxmox.md`
- `../../Infrastructure/network.md`

---

## 1. Download Ubuntu Template

Masuk ke Proxmox Web UI:

```
Datacenter
└── haytham
    └── local
        └── CT Templates
```

Download:

```
ubuntu-24.04-standard
```

---

## 2. Create New LXC

Klik:

```
Create CT
```

---

## 3. General Configuration

| Field | Value |
|---|---|
| Node | haytham |
| CT ID | Sesuai perencanaan |
| Hostname | Sesuai role |
| Password | Generate password kuat dan simpan di Vaultwarden |
| Unprivileged Container | ✅ Enabled |

Contoh:

| CT ID | Hostname | Role |
|---|---|---|
| 101 | core-infra | DNS, reverse proxy, monitoring |
| 102 | security | Vaultwarden |
| 103 | database | PostgreSQL & Redis |
| 104 | auth | Authentik |
| 105 | productivity | User applications |

---

## 4. Template

Pilih:

```
ubuntu-24.04-standard
```

---

## 5. Disk

Konfigurasi disk sesuai kebutuhan service.

Contoh alokasi saat ini:

| LXC | Disk |
|---|---|
| 101 | 8 GB |
| 102 | 4 GB |
| 103 | 16 GB |
| 104 | 16 GB |
| 105 | 16 GB |

Gunakan storage:

```
local-lvm
```

---

## 6. CPU

Konfigurasi CPU sesuai workload.

Contoh:

| LXC | CPU |
|---|---|
| 101 | 2 core |
| 102 | 1 core |
| 103 | 2 core |
| 104 | 2 core |
| 105 | 2 core |

---

## 7. Memory

Konfigurasi RAM dan swap.

Contoh:

| LXC | RAM | Swap |
|---|---|---|
| 101 | 768 MB | 512 MB |
| 102 | 256 MB | 256 MB |
| 103 | 1024 MB | 512 MB |
| 104 | 2048 MB | 1024 MB |
| 105 | 1024 MB | 512 MB |

> Sesuaikan dengan kapasitas hardware saat ini. Lihat `../../Infrastructure/hardware.md` untuk RAM budget dan upgrade plan.

---

## 8. Network

Gunakan konfigurasi berikut:

| Field | Value |
|---|---|
| Bridge | vmbr0 |
| IPv4 | Static |
| Gateway | 192.168.100.1 |

Contoh:

| LXC | IP |
|---|---|
| 101 | 192.168.100.101/24 |
| 102 | 192.168.100.102/24 |
| 103 | 192.168.100.103/24 |
| 104 | 192.168.100.104/24 |
| 105 | 192.168.100.105/24 |

DNS:

- LXC 101 → `1.1.1.1`
- LXC lain → `192.168.100.101`

Search domain:

```
homelab.local
```

> LXC 101 tidak menggunakan Pi-hole sebagai DNS untuk menghindari circular dependency.

---

## 9. Confirm

Sebelum klik **Finish**, verifikasi:

- Unprivileged container aktif
- IP address benar
- CPU dan RAM sesuai perencanaan
- DNS sesuai role

---

## 10. Enable Nesting

Setelah LXC selesai dibuat, aktifkan fitur nesting agar Docker dapat berjalan.

### Via Proxmox Web UI

```
CT
└── Options
    └── Features
        └── Nesting → Enable
```

---

### Via CLI

Ganti `<CT_ID>` dengan ID container:

```bash
pct set <CT_ID> -features nesting=1
```

Contoh:

```bash
pct set 101 -features nesting=1
```

---

## 11. Start LXC

Jalankan container:

```bash
pct start <CT_ID>
```

Masuk ke console:

```bash
pct enter <CT_ID>
```

Verifikasi network:

```bash
ip a
ping 192.168.100.1
ping google.com
```

Verifikasi DNS:

```bash
resolvectl status
```

> Apabila `resolvectl` tidak tersedia, cek file:

```bash
cat /etc/resolv.conf
```

---

## 12. Update Operating System

Jalankan update awal:

```bash
apt update
apt upgrade -y
apt autoremove -y
```

Reboot apabila diperlukan:

```bash
reboot
```

---

## Post-Creation Checklist

- [ ] LXC berhasil dibuat
- [ ] Unprivileged mode aktif
- [ ] Nesting aktif
- [ ] Static IP dapat diakses
- [ ] Gateway reachable
- [ ] DNS resolution berjalan
- [ ] Package berhasil di-update

---

## Next Step

Setelah LXC selesai dibuat:

1. Install Docker:
   - `docker-installation.md`

2. Deploy service sesuai role:
   - LXC 101 → Core Infrastructure
   - LXC 102 → Security
   - LXC 103 → Database
   - LXC 104 → Authentication
   - LXC 105 → Productivity

---

*Last updated: 2026-06-18*