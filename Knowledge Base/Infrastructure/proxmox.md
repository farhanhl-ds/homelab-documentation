# Proxmox Host

Dokumentasi konfigurasi dan baseline Proxmox VE sebagai hypervisor utama homelab.

## Host Information

|          |                               |
| -------- | ----------------------------- |
| Version  | Proxmox VE 9.2.3              |
| Host IP  | `192.168.100.10`              |
| Web UI   | `https://192.168.100.10:8006` |
| Hostname | `haytham.homelab.local`       |

## BIOS Baseline Configuration

Konfigurasi BIOS yang diperlukan agar Proxmox dapat berjalan secara optimal.

* **Boot Priority** — SSD memiliki prioritas boot lebih tinggi dibanding PXE agar sistem tidak mencoba melakukan network boot saat restart.
* **Secure Boot** — Nonaktif karena tidak digunakan pada konfigurasi Proxmox saat ini.
* **Intel VT-x / VT-d** — Aktif untuk mendukung virtualisasi penuh dan fitur PCI passthrough.

## LXC Startup Sequence

Seluruh LXC dikonfigurasi auto-start ketika Proxmox host melakukan boot ulang, misalnya setelah power failure.

| LXC                  | Order | Delay | Purpose                                                                                    |
| -------------------- | ----- | ----- | ------------------------------------------------------------------------------------------ |
| 101 (`core-infra`)   | 1     | 30s   | Pi-hole dan Nginx Proxy Manager harus tersedia terlebih dahulu sebagai core infrastructure |
| 102 (`security`)     | 2     | 20s   | Vaultwarden                                                                                |
| 103 (`database`)     | 3     | 20s   | PostgreSQL dan Redis sebagai dependency service lain                                       |
| 104 (`auth`)         | 4     | 10s   | Authentication services                                                                    |
| 105 (`productivity`) | 5     | 10s   | Productivity services                                                                      |

Startup sequence dibuat berdasarkan dependency antar service agar layanan yang menjadi fondasi infrastructure tersedia sebelum service yang bergantung padanya melakukan startup.

## Related Runbooks

* `Runbooks/proxmox-post-install.md` — Konfigurasi awal setelah instalasi Proxmox.
* `Runbooks/proxmox-lxc-startup.md` — Cara mengatur, mengubah, dan memverifikasi konfigurasi LXC auto-start.

---

*Last updated: 2026-06-17*
