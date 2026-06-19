# Tailscale Remote Access Configuration

Panduan konfigurasi Tailscale untuk mengakses homelab secara remote tanpa melakukan port forwarding.

---

## Overview

Tailscale membentuk private mesh VPN menggunakan WireGuard.

Setiap device yang tergabung ke Tailnet akan mendapatkan IP Tailscale:

```
100.x.x.x
```

Dengan Tailscale, service homelab dapat diakses secara aman dari luar jaringan rumah.

---

## Architecture

```text
Remote Device
      |
      |
      v
 Tailscale Network
      |
      |
      v
 Homelab Node
      |
      |
      v
 Internal LAN
192.168.100.0/24
```

---

## Design Decision

Homelab menggunakan:

- Tailscale sebagai remote access
- Tidak menggunakan port forwarding
- Tidak mengekspos Nginx Proxy Manager ke internet
- Semua akses dilakukan melalui private Tailnet

Keuntungan:

- Mengurangi attack surface
- Tidak perlu dynamic DNS
- Tidak perlu public SSL certificate
- Encrypted end-to-end

---

# Installation

## Install Tailscale pada Linux

Jalankan:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

Verifikasi:

```bash
tailscale version
```

---

## Login ke Tailnet

Jalankan:

```bash
sudo tailscale up
```

Akan muncul URL login.

Buka URL tersebut dan login menggunakan akun Tailscale.

---

## Verify Connection

Cek status:

```bash
tailscale status
```

Contoh:

```text
100.x.x.10    homelab-server
100.x.x.20    laptop
100.x.x.30    phone
```

---

# Homelab Deployment Options

Ada beberapa cara menjalankan Tailscale.

---

## Option A — Install pada Proxmox Host (Recommended)

```
Proxmox Host
      |
      |
Tailscale
      |
      |
LXC Network
192.168.100.0/24
```

Keuntungan:

- Satu koneksi untuk seluruh homelab
- Tidak perlu install Tailscale di setiap LXC
- Lebih mudah maintenance

Konfigurasi subnet router:

```bash
sudo tailscale up \
--advertise-routes=192.168.100.0/24
```

Kemudian buka:

```
Tailscale Admin Console
↓
Machines
↓
Approve Routes
```

---

## Option B — Install pada setiap LXC

Contoh:

```
LXC 101
100.x.x.x

LXC 102
100.x.x.x

LXC 103
100.x.x.x
```

Tidak direkomendasikan karena:

- Banyak node Tailscale
- Maintenance lebih sulit
- ACL lebih kompleks

---

# Accessing Services

Setelah subnet router aktif, device remote dapat mengakses:

```
https://homepage.homelab.local
https://auth.homelab.local
https://outline.homelab.local
https://vault.homelab.local
```

dengan syarat:

- Device menggunakan Pihole sebagai DNS, atau
- Tailscale DNS dikonfigurasi untuk mengarahkan `homelab.local`

---

# Configure DNS with Tailscale

Agar domain internal tetap bekerja dari luar rumah.

Masuk ke:

```
Tailscale Admin Console
↓
DNS
```

Tambahkan:

```
Nameserver:
192.168.100.101
```

Aktifkan:

```
Override local DNS
```

Dengan konfigurasi ini:

```
auth.homelab.local
        |
        v
Pihole
        |
        v
NPM
        |
        v
Service
```

---

# Testing

## Test Tailnet Connectivity

Ping gateway:

```bash
ping 192.168.100.101
```

Expected:

```
Reply from 192.168.100.101
```

---

## Test DNS

Linux:

```bash
dig auth.homelab.local
```

Expected:

```
auth.homelab.local IN A 192.168.100.101
```

---

## Test HTTPS

Buka:

```
https://auth.homelab.local
```

Pastikan:

- Tailscale connected
- DNS resolve berhasil
- SSL certificate diterima

---

# Security Recommendations

## Enable Tailscale MFA

Aktifkan MFA pada akun Tailscale untuk mencegah unauthorized access.

---

## Use ACL

Contoh policy:

```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["user@example.com"],
      "dst": ["192.168.100.0/24:*"]
    }
  ]
}
```

ACL memungkinkan pembatasan akses antar device.

---

## Disable Unnecessary Services

Walaupun jaringan private:

- Jangan expose port yang tidak diperlukan
- Tetap gunakan password yang kuat
- Simpan credential di Vaultwarden

---

# Troubleshooting

## Cannot access homelab from remote

Periksa:

- Tailscale status connected
- Subnet route sudah di-approve
- Device berada dalam Tailnet yang sama

---

## DNS works at home but not remote

Penyebab:

Tailscale DNS belum menggunakan Pihole.

Periksa:

```
Tailscale Admin Console
↓
DNS
↓
Nameserver
```

Pastikan mengarah ke:

```
192.168.100.101
```

---

## SSL Warning

Periksa:

- Certificate `homelab-local` sudah terinstall pada device remote
- Device menggunakan DNS yang benar

---

# Maintenance Checklist

Setelah setup selesai:

- [ ] Tailscale terinstall pada Proxmox Host
- [ ] Tailnet login berhasil
- [ ] Subnet route `192.168.100.0/24` di-advertise
- [ ] Route di-approve melalui Admin Console
- [ ] DNS menggunakan Pihole
- [ ] Remote device dapat membuka `*.homelab.local`
- [ ] MFA Tailscale aktif

---

# Related Documents

- `pihole-dns-records.md`
- `ssl-self-signed.md`
- `npm-proxy-host.md`

---

*Last updated: 2026-06-19*