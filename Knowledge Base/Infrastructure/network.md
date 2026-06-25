# Network

Dokumentasi arsitektur jaringan, alokasi IP, konfigurasi DNS, dan SSL certificate pada environment homelab.

## Network Topology

```
Internet
   │
   ▼
Router IndiHome (192.168.100.1)
   │
   ▼
Proxmox Host — haytham (192.168.100.10)
   ├── LXC 101 — core-infra     (192.168.100.101)
   ├── LXC 102 — security       (192.168.100.102)
   ├── LXC 103 — database       (192.168.100.103)
   ├── LXC 104 — auth           (192.168.100.104)
   ├── LXC 105 — productivity   (192.168.100.105)
   └── VM 100  — HAOS           (192.168.100.100)
```

## IP Address Allocation & DNS Configuration

| IP              | Hostname                     | Role                          | DNS               |
| --------------- | ---------------------------- | ----------------------------- | ----------------- |
| 192.168.100.1   | —                            | Router IndiHome               | —                 |
| 192.168.100.10  | `haytham.homelab.local`      | Proxmox host                  | `1.1.1.1`         |
| 192.168.100.100 | —                            | Home Assistant OS             | `192.168.100.101` |
| 192.168.100.101 | `core-infra.homelab.local`   | LXC 101 — Core Infrastructure | `1.1.1.1` ⚠️      |
| 192.168.100.102 | `security.homelab.local`     | LXC 102 — Security            | `192.168.100.101` |
| 192.168.100.103 | `database.homelab.local`     | LXC 103 — Database            | `192.168.100.101` |
| 192.168.100.104 | `auth.homelab.local`         | LXC 104 — Authentication      | `192.168.100.101` |
| 192.168.100.105 | `productivity.homelab.local` | LXC 105 — Productivity        | `192.168.100.101` |

> ⚠️ **LXC 101 tidak menggunakan Pi-hole sebagai DNS server.**
> LXC 101 menjalankan Pi-hole sehingga menggunakan DNS lokal (`192.168.100.101`) akan menyebabkan circular dependency. Apabila Pi-hole tidak berjalan, LXC 101 akan kehilangan kemampuan DNS resolution. Oleh karena itu LXC 101 menggunakan external DNS seperti `1.1.1.1` atau `8.8.8.8`.

## SSL Certificate

|                  |                                  |
| ---------------- | -------------------------------- |
| Certificate Type | Self-signed wildcard certificate |
| Domain           | `*.homelab.local`                |
| Validity         | ±10 tahun (hingga sekitar 2036)  |

### Certificate Storage

| Asset                       | Location                                      |
| --------------------------- | --------------------------------------------- |
| Certificate (`homelab.crt`) | LXC 101 — `/opt/stacks/npm/homelab.crt`       |
| Private Key (`homelab.key`) | LXC 101 — `/opt/stacks/npm/homelab.key`       |
| Local Backup                | Windows laptop — `C:\Users\Farhan\Downloads\` |
| Secure Backup               | Vaultwarden — Note "SSL Certificate"          |

### Current SSL Deployment

* Wildcard certificate tersedia di Nginx Proxy Manager dengan nama `homelab-local`.
* Seluruh proxy host menggunakan wildcard certificate tersebut.
* Root certificate telah di-install pada Windows Certificate Store sehingga browser mempercayai domain internal `*.homelab.local`.

## Related Runbooks

* `Runbooks/ssl-self-signed.md` — Generate certificate, deployment awal, dan instalasi ke client device.

---

*Last updated: 2026-06-17*
