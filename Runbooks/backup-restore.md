Panduan backup dan restore untuk seluruh data homelab. Mengingat storage menggunakan single SSD tanpa redundancy, backup rutin ke external storage sangat direkomendasikan.

---

## Strategi Backup

| Layer | Method | Frekuensi | Status |
|---|---|---|---|
| Proxmox LXC snapshot | Proxmox Backup via UI atau CLI | Bulanan | 🔲 Belum dikonfigurasi |
| Docker volumes & config | Manual `tar` + `scp` | Setiap ada perubahan signifikan | 🔲 Belum dikonfigurasi |
| Vaultwarden data | Manual `scp` | Mingguan | 🔲 Belum dikonfigurasi |

> ⚠️ **Storage menggunakan single SSD tanpa redundancy.** Apabila SSD gagal tanpa backup, seluruh data homelab tidak dapat dipulihkan. Backup ke external storage (USB drive atau cloud) sangat direkomendasikan.

---

## Lokasi Data Penting

| Service | LXC | Data Location |
|---|---|---|
| Portainer | 101 | Docker named volume: `portainer_data` |
| Pihole | 101 | `/opt/stacks/pihole/etc-pihole/`, `/opt/stacks/pihole/etc-dnsmasq.d/` |
| NPM | 101 | `/opt/stacks/npm/data/`, `/opt/stacks/npm/letsencrypt/` |
| Homepage | 101 | `/opt/stacks/homepage/config/` |
| Uptime Kuma | 101 | `/opt/stacks/uptime-kuma/data/` |
| Vaultwarden | 102 | `/opt/stacks/vaultwarden/data/` |
| PostgreSQL | 103 | `/opt/stacks/database/pgdata/` |
| Redis | 103 | `/opt/stacks/database/redisdata/` |
| Authentik | 104 | `/opt/stacks/authentik/media/`, `/opt/stacks/authentik/certs/` |
| Outline | 105 | `/opt/stacks/outline/data/` |
| Postiz | 105 | `/opt/stacks/postiz/uploads/` |
| HAOS | VM 100 | Backup via Proxmox VM backup |

---

## Backup LXC via Proxmox

### Manual via UI

1. Proxmox Web UI → pilih LXC → **Backup** → **Backup now**
2. Storage: `local`
3. Mode: `Snapshot` (apabila didukung) atau `Stop`

### Manual via CLI

```bash
# Backup satu LXC
vzdump 101 --storage local --compress zstd

# Backup semua LXC sekaligus
vzdump --all --storage local --compress zstd
```

File backup tersimpan di `/var/lib/vz/dump/`.

---

## Backup Docker Volumes & Config

```bash
# Backup seluruh folder stacks
tar -czvf /root/backup-stacks-$(date +%Y%m%d).tar.gz /opt/stacks/

# Copy ke external storage atau server lain
scp /root/backup-stacks-*.tar.gz user@backup-server:/backups/
```

---

## Restore LXC dari Backup

### Via UI

1. Proxmox Web UI → **Storage** → **local** → **Backups**
2. Pilih file backup → **Restore**
3. Set CT ID dan konfigurasi network

### Via CLI

```bash
pct restore 101 /var/lib/vz/dump/vzdump-lxc-101-*.tar.zst --storage local-lvm
```

---

## Restore Docker Services

```bash
# Extract backup
tar -xzvf backup-stacks-YYYYMMDD.tar.gz -C /

# Jalankan ulang services per LXC
cd /opt/stacks/pihole && docker compose up -d
cd /opt/stacks/npm && docker compose up -d
cd /opt/stacks/vaultwarden && docker compose up -d
# dan seterusnya sesuai urutan deploy
```

---

## Last Backup

| Tanggal | Scope | Lokasi |
|---|---|---|
| — | — | — |

---

*Last updated: 2026-06-16*
