# Hardware

Dokumentasi spesifikasi physical host, kapasitas resource, dan perencanaan upgrade untuk environment homelab.

## Host Information

| Component        | Details                                          |
| ---------------- | ------------------------------------------------ |
| Device           | Lenovo ThinkCentre M910q Tiny                    |
| CPU              | Intel Core i5-7500 @ 3.40GHz (4 core / 4 thread) |
| Memory           | 8GB DDR4 single channel                          |
| Storage          | 980GB Kingston SA400S3 SATA SSD                  |
| Operating System | Proxmox VE 9.2.3                                 |

## Planned Hardware Upgrade

| Component | Target                 | Status     |
| --------- | ---------------------- | ---------- |
| Memory    | 16GB DDR4 dual channel | 🔲 Pending |

Upgrade RAM menjadi 16GB direncanakan untuk memberikan kapasitas yang lebih aman ketika seluruh LXC dan VM berjalan secara bersamaan.

## Resource Allocation

| Guest                         | Allocated Memory |
| ----------------------------- | ---------------- |
| Proxmox host (reserved)       | ~1–2GB           |
| LXC 101 — Core Infrastructure | 768MB            |
| LXC 102 — Security            | 256MB            |
| LXC 103 — Database            | 1024MB           |
| LXC 104 — Authentication      | 2048MB           |
| LXC 105 — Productivity        | 1024MB           |
| VM 100 — Home Assistant OS    | 2048MB           |
| **Total Guest Allocation**    | **~7.1GB**       |

Dengan kapasitas host saat ini (8GB), total alokasi guest mendekati batas maksimum memory yang tersedia. Menjalankan seluruh LXC dan VM secara bersamaan berpotensi menyebabkan memory pressure, penggunaan swap, atau kondisi Out Of Memory (OOM).

Upgrade ke 16GB direkomendasikan sebelum seluruh environment production berjalan secara penuh.

## Storage Consideration

Storage menggunakan single SSD tanpa redundancy. Oleh karena itu backup rutin menjadi bagian penting dari disaster recovery strategy.

Related runbook:

* `Runbooks/backup-restore.md` — Backup schedule, restore procedure, dan recovery process.

---

*Last updated: 2026-06-17*
