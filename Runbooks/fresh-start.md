Panduan untuk menghapus seluruh LXC/VM dan melakukan deploy ulang dari awal. Gunakan apabila setup mengalami masalah yang lebih efisien diselesaikan dengan fresh deploy dibanding diperbaiki satu per satu.

> **Perhatian:** Proxmox host (haytham) dan data di storage tidak ikut terhapus — hanya LXC/VM yang di-destroy.

---

## Sebelum Memulai

- [ ] Backup konfigurasi penting apabila ada yang perlu disimpan (`docker-compose.yml`, `.env` files, dll)
- [ ] Pastikan seluruh password tersimpan di tempat yang aman apabila Vaultwarden ikut di-destroy
- [ ] Pastikan akses ke Proxmox UI tersedia: `https://192.168.100.10:8006`

---

## Urutan Destroy

Destroy dilakukan dengan urutan kebalikan dari deploy — dimulai dari LXC yang paling sedikit dependensinya:

```
VM 100 → LXC 105 → LXC 104 → LXC 103 → LXC 102 → LXC 101
```

### Langkah per LXC/VM

1. Di Proxmox UI, klik LXC/VM di sidebar
2. Apabila masih running → klik **Shutdown** → tunggu hingga stopped
3. Klik **More** → **Remove**
4. Di dialog konfirmasi:
   - Ketik **ID number** LXC untuk konfirmasi
   - Centang **"Destroy unreferenced disks owned by guest"**
5. Klik **Remove**

Ulangi untuk seluruh LXC/VM sesuai urutan di atas.

---

## Verifikasi Setelah Destroy

### Via CLI

```bash
# Di Proxmox host shell
lvs | grep -v "pve"
```

Output harus kosong.

### Via UI

1. Sidebar → klik **local-lvm (haytham)**
2. **CT Volumes** — pastikan kosong
3. **VM Disks** — pastikan kosong

---

## Fresh Deploy

### Step 1 — Proxmox Post-Install

Apabila Proxmox juga di-reinstall, jalankan community script post-install terlebih dahulu:

```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pve-install.sh)"
```

Script ini melakukan:

| Action | Keterangan |
|---|---|
| Disable pve-enterprise repository | Tidak diperlukan untuk homelab |
| Add pve-no-subscription repository | Repository gratis |
| Disable subscription nag | Menghilangkan popup subscription |
| Disable high availability | Tidak diperlukan untuk single node |

### Step 2 — Deploy LXC/VM

Ikuti urutan deploy berikut:

| Urutan | Target | Referensi |
|---|---|---|
| 1 | LXC 101 — core-infra | [lxc-101-core-infra.md](../nodes/lxc-101-core-infra.md) |
| 2 | LXC 102 — security | [lxc-102-security.md](../nodes/lxc-102-security.md) |
| 3 | LXC 103 — database | [lxc-103-database.md](../nodes/lxc-103-database.md) |
| 4 | LXC 104 — auth | [lxc-104-auth.md](../nodes/lxc-104-auth.md) |
| 5 | LXC 105 — productivity | [lxc-105-productivity.md](../nodes/lxc-105-productivity.md) |
| 6 | VM 100 — HAOS | [vm-100-haos.md](../nodes/vm-100-haos.md) |
| 7 | Network setup | [network-setup.md](./network-setup.md) |

Untuk langkah pembuatan tiap LXC → lihat [create-lxc-guide.md](./create-lxc-guide.md).

---

## Catatan

- Destroy dan deploy dilakukan satu per satu — jangan sekaligus
- Setelah LXC 102 (Vaultwarden) running, simpan seluruh credential sebelum melanjutkan ke LXC berikutnya
- Apabila hanya satu service yang bermasalah, tidak perlu full fresh start — cukup destroy LXC yang bersangkutan saja

---

*Last updated: 2026-06-16*
