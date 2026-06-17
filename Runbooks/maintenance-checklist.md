Checklist pemeliharaan rutin homelab. Disarankan dilakukan setiap bulan bersamaan dengan backup rutin.

---

## Pre-Maintenance

- [ ] Catat seluruh service yang sedang running
- [ ] Pastikan backup terbaru sudah tersedia sebelum memulai — lihat [backup-restore.md](./backup-restore.md)
- [ ] Set reminder kalender untuk maintenance berikutnya

---

## Proxmox Host

- [ ] Update Proxmox VE: `apt update && apt dist-upgrade -y`
- [ ] Cek health storage: `smartctl -a /dev/sda`
- [ ] Review resource usage tiap LXC/VM di Proxmox dashboard
- [ ] Hapus snapshot lama yang tidak lagi diperlukan
- [ ] Verifikasi LXC baru sudah di-set `--onboot 1` — lihat [proxmox.md](../Infrastructure/proxmox.md#lxc-auto-start-on-boot)

---

## Per LXC / VM

Ulangi untuk setiap LXC yang running:

- [ ] `apt update && apt upgrade -y`
- [ ] `docker compose pull` — update seluruh images ke versi terbaru
- [ ] `docker compose up -d` — restart dengan image baru
- [ ] `docker image prune -f` — hapus image lama yang tidak digunakan
- [ ] Review log container: `docker compose logs --tail=100`

---

## Pihole

- [ ] Update gravity (blocklist): Admin UI → **Tools** → **Update Gravity**
- [ ] Review query log — pastikan tidak ada anomali
- [ ] Backup config Pihole

---

## Nginx Proxy Manager

- [ ] Review seluruh proxy hosts — hapus yang sudah tidak digunakan
- [ ] Verifikasi SSL certificate masih valid — self-signed cert tidak auto-renew, expire ~2036

---

## Post-Maintenance

- [ ] Verifikasi seluruh service accessible via URL masing-masing
- [ ] Update `Last updated` di file node yang mengalami perubahan
- [ ] Catat perubahan signifikan di PROGRESS.md

---

## Log Maintenance

| Tanggal | Catatan |
|---|---|
| — | Initial setup |

---

*Last updated: 2026-06-16*
