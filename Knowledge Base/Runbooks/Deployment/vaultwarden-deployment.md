# Vaultwarden Deployment

Panduan deployment Vaultwarden sebagai password manager self-hosted untuk menyimpan seluruh credential dan secret homelab.

Vaultwarden berjalan pada LXC 102 (`security`).

---

## Prerequisites

Pastikan:

- LXC 102 sudah dibuat
- Docker sudah terinstall
- Pi-hole dan Nginx Proxy Manager sudah berjalan
- DNS record `vault.homelab.local` sudah dibuat dan mengarah ke NPM
- SSL certificate `homelab-local` sudah tersedia di NPM

Referensi:

- `create-lxc-guide.md`
- `docker-installation.md`
- `pihole-dns-records.md`
- `nginx-proxy-manager-deployment.md`

---

## 1. Create Stack Directory

```bash
mkdir -p /opt/stacks/vaultwarden
cd /opt/stacks/vaultwarden
```

---

## 2. Generate Admin Token

Generate token untuk mengakses admin panel:

```bash
openssl rand -base64 48
```

Simpan token ini di tempat sementara.

> Setelah Vaultwarden selesai dikonfigurasi, pindahkan token ke Vaultwarden pada note khusus Homelab Security.

---

## 3. Create docker-compose.yml

Buat file:

```bash
nano docker-compose.yml
```

Isi:

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped

    ports:
      - "8080:80"

    environment:
      DOMAIN: "https://vault.homelab.local"
      SIGNUPS_ALLOWED: "false"
      ADMIN_TOKEN: "your_admin_token"

    volumes:
      - ./data:/data
```

---

## 4. Deploy Container

Jalankan:

```bash
docker compose up -d
```

Verifikasi:

```bash
docker ps
```

Expected:

```text
vaultwarden   Up
```

---

## 5. Configure NPM Proxy Host

Buat Proxy Host baru:

| Field | Value |
|---|---|
| Domain Names | `vault.homelab.local` |
| Scheme | `http` |
| Forward Hostname | `192.168.100.102` |
| Forward Port | `8080` |
| Websockets | Enable |
| Block Common Exploits | Enable |

Tab SSL:

| Field | Value |
|---|---|
| SSL Certificate | `homelab-local` |
| Force SSL | Enable |
| HTTP/2 Support | Enable |

---

## 6. Create First Account

Karena registration dinonaktifkan:

```env
SIGNUPS_ALLOWED=false
```

Maka lakukan langkah berikut:

Ubah sementara:

```env
SIGNUPS_ALLOWED=true
```

Reload container:

```bash
docker compose up -d --force-recreate
```

Buka:

```
https://vault.homelab.local
```

Buat akun utama.

---

## 7. Disable Public Signup

Setelah akun pertama selesai dibuat:

Ubah kembali:

```env
SIGNUPS_ALLOWED=false
```

Kemudian:

```bash
docker compose up -d --force-recreate
```

Verifikasi:

- Account baru tidak bisa dibuat melalui halaman registrasi.
- Akun administrator tetap dapat login.

---

## 8. Install Bitwarden Client

Install aplikasi Bitwarden:

- Browser Extension
- Desktop Application
- Mobile Application

Ubah Server URL menjadi:

```
https://vault.homelab.local
```

Login menggunakan akun yang sudah dibuat.

---

## 9. Import Existing Passwords

Contoh dari Google Chrome:

1. Chrome → Settings
2. Password Manager
3. Export Passwords → `.csv`

Di Vaultwarden:

```
Tools
→ Import Data
→ Format: Chrome (csv)
→ Import
```

Setelah berhasil:

- Verifikasi seluruh credential muncul
- Hapus file CSV export

⚠️ File CSV berisi password dalam bentuk plaintext.

---

## 10. Store Homelab Secrets

Buat struktur awal di Vaultwarden.

Contoh:

```
Homelab
│
├── Infrastructure
│   ├── Proxmox
│   ├── Router
│   └── Tailscale
│
├── Core Services
│   ├── Pi-hole
│   ├── Nginx Proxy Manager
│   └── SSL Certificate
│
├── Database
│   ├── PostgreSQL
│   └── Redis
│
└── Applications
    ├── Authentik
    ├── Outline
    └── Postiz
```

---

## Security Hardening

### Hash Admin Token (Recommended)

Default:

```env
ADMIN_TOKEN=plain_text_token
```

Vaultwarden akan menampilkan warning.

Gunakan Argon2 hash agar token tidak tersimpan sebagai plaintext.

Referensi:

```
https://github.com/dani-garcia/vaultwarden/wiki/Enabling-admin-page
```

---

### Enable Two-Factor Authentication

Masuk ke:

```
Account Settings → Two-step Login
```

Aktifkan:

- TOTP Authenticator
- Recovery Code

Simpan recovery code di tempat aman.

---

## Verification

Pastikan:

- URL dapat diakses:

```
https://vault.homelab.local
```

- HTTPS certificate valid
- Login berhasil
- Admin panel dapat diakses:

```
https://vault.homelab.local/admin
```

---

## Troubleshooting

### Tidak bisa login ke admin panel

Periksa:

- `ADMIN_TOKEN` benar
- Container sudah direstart setelah perubahan

Cek log:

```bash
docker logs vaultwarden
```

---

### Tidak bisa diakses dari domain

Periksa DNS:

```bash
nslookup vault.homelab.local 192.168.100.101
```

Periksa NPM Proxy Host:

- Domain benar
- Forward IP benar
- SSL aktif

---

## Post-Deployment Checklist

- [ ] Vaultwarden container running
- [ ] Domain `vault.homelab.local` dapat diakses
- [ ] SSL aktif melalui NPM
- [ ] Akun pertama dibuat
- [ ] Signup kembali dinonaktifkan
- [ ] Password lama berhasil diimport
- [ ] Bitwarden client menggunakan self-hosted URL
- [ ] Admin token disimpan aman
- [ ] 2FA diaktifkan
- [ ] ADMIN_TOKEN di-hash menggunakan Argon2

---

## Next Step

Setelah Vaultwarden siap:

1. Deploy PostgreSQL + Redis
2. Generate seluruh database credential
3. Simpan semua secret langsung ke Vaultwarden

Runbook berikutnya:

`database-deployment.md`

---

*Last updated: 2026-06-18*