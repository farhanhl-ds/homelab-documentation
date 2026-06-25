# Tailscale

Tailscale digunakan sebagai solusi remote access ke homelab tanpa membuka port ke internet. Seluruh device yang bergabung ke tailnet dapat mengakses service internal melalui jaringan Tailscale seolah berada dalam jaringan lokal yang sama.

## Architecture

|                   |                                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------------- |
| Host              | Proxmox host (`haytham`)                                                                          |
| Deployment Mode   | Subnet router                                                                                     |
| Advertised Subnet | `192.168.100.0/24`                                                                                |
| Authentication    | Tailscale account (Google / GitHub / Microsoft)                                                   |
| DNS Handling      | Tailscale tidak mengelola DNS host (`accept-dns=false`) karena DNS internal dikelola oleh Pi-hole |

Tailscale hanya diinstall pada Proxmox host sebagai subnet router. Seluruh LXC dan VM di belakang subnet `192.168.100.0/24` dapat diakses dari device lain dalam tailnet tanpa perlu menginstall Tailscale pada masing-masing container atau VM.

## Access Capability

Setelah subnet route aktif, device yang bergabung ke tailnet dapat mengakses service internal menggunakan IP lokal, contohnya:

```
https://192.168.100.10:8006    # Proxmox
https://192.168.100.101:81     # Nginx Proxy Manager
https://192.168.100.101:8080   # Pi-hole
```

## DNS Integration (Future Plan)

Untuk mendukung akses domain internal dari luar jaringan, Tailscale dapat diintegrasikan dengan MagicDNS menggunakan custom nameserver yang mengarah ke Pi-hole (`192.168.100.101`).

Perlu diperhatikan bahwa apabila Pi-hole tidak berjalan, resolusi domain internal melalui Tailscale juga akan gagal karena Pi-hole menjadi dependency utama untuk DNS internal.

Detail konfigurasi DNS dan dependency terkait dijelaskan pada `network.md`.

## Related Runbooks

* `Runbooks/tailscale-setup.md` — Instalasi Tailscale, autentikasi, subnet route approval, dan verifikasi koneksi.

---

*Last updated: 2026-06-17*
