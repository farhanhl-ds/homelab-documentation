# Nginx Proxy Manager Deployment

Panduan deployment Nginx Proxy Manager (NPM) sebagai reverse proxy utama untuk seluruh service homelab.

NPM berjalan pada LXC 101 (`core-infra`) dan menangani routing domain internal `*.homelab.local` menggunakan SSL certificate self-signed.

---

## Prerequisites

Pastikan:

- LXC 101 sudah dibuat
- Docker sudah terinstall
- Pi-hole sudah berjalan dan berfungsi
- Directory `/opt/stacks` tersedia

Referensi:

- `create-lxc-guide.md`
- `docker-installation.md`
- `pihole-deployment.md`

---

## 1. Create Stack Directory

```bash
mkdir -p /opt/stacks/npm
cd /opt/stacks/npm
```

---

## 2. Create docker-compose.yml

Buat file:

```bash
nano docker-compose.yml
```

Isi:

```yaml
services:
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: npm
    restart: unless-stopped

    ports:
      - "80:80"
      - "443:443"
      - "81:81"

    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```

---

## 3. Deploy Container

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
npm    Up
```

---

## 4. Initial Login

Akses web UI:

```text
http://192.168.100.101:81
```

Default credential:

```text
Email:
admin@example.com

Password:
changeme
```

Setelah login pertama:

- Ubah email administrator
- Buat password baru yang kuat
- Simpan credential ke Vaultwarden

---

## 5. Import SSL Certificate

Masuk ke:

```text
SSL Certificates
→ Add SSL Certificate
→ Custom
```

Upload:

| File | Lokasi |
|---|---|
| Certificate | `homelab.crt` |
| Private Key | `homelab.key` |

Beri nama:

```text
homelab-local
```

---

## 6. Proxy Host Convention

Gunakan standar berikut untuk seluruh service:

| Service | Domain |
|---|---|
| NPM | npm.homelab.local |
| Pi-hole | pihole.homelab.local |
| Vaultwarden | vault.homelab.local |
| Authentik | auth.homelab.local |
| Outline | outline.homelab.local |
| Adminer | adminer.homelab.local |
| Homepage | homepage.homelab.local |
| Uptime Kuma | uptime.homelab.local |
| Postiz | postiz.homelab.local |
| Stirling PDF | stirling.homelab.local |

---

## 7. Create Proxy Host

Untuk setiap service:

```
Proxy Hosts
→ Add Proxy Host
```

Konfigurasi standar:

| Field | Value |
|---|---|
| Scheme | http |
| Websockets Support | Enable |
| Block Common Exploits | Enable |
| Cache Assets | Disable |
| SSL Certificate | homelab-local |
| Force SSL | Enable |
| HTTP/2 Support | Enable |
| HSTS | Disable |

> HSTS dinonaktifkan karena homelab menggunakan self-signed certificate. Mengaktifkan HSTS dapat menyebabkan browser memaksa HTTPS walaupun terdapat masalah certificate.

---

## 8. DNS Records

Pastikan seluruh domain mengarah ke:

```text
192.168.100.101
```

Contoh:

```text
auth.homelab.local
        ↓
192.168.100.101
        ↓
NPM
        ↓
192.168.100.104:9000
```

Konfigurasi DNS record dilakukan melalui Pi-hole.

---

## 9. Verification

Test akses:

```text
https://npm.homelab.local
```

Pastikan:

- Domain berhasil di-resolve
- HTTPS menggunakan certificate `homelab-local`
- Browser tidak menampilkan certificate warning (setelah root certificate di-install)

---

## Security Notes

- Jangan expose port `81`, `80`, atau `443` ke internet menggunakan port forwarding.
- Remote access dari luar jaringan menggunakan Tailscale.
- Simpan credential administrator NPM di Vaultwarden.
- Semua proxy host wajib menggunakan HTTPS.

---

## Troubleshooting

### Proxy Host menampilkan Bad Gateway (502)

Periksa:

- Container target berjalan:
```bash
docker ps
```

- IP dan port tujuan benar
- Service mendengarkan pada interface yang benar

---

### Domain tidak dapat diakses

Test DNS:

```bash
nslookup auth.homelab.local 192.168.100.101
```

Expected:

```text
Address: 192.168.100.101
```

---

### SSL Certificate tidak muncul

Periksa:

- Certificate sudah di-upload dengan nama `homelab-local`
- Proxy Host menggunakan certificate yang benar
- Force SSL aktif

---

## Post-Deployment Checklist

- [ ] NPM container running
- [ ] Login administrator berhasil
- [ ] Password default diganti
- [ ] Credential disimpan di Vaultwarden
- [ ] SSL certificate `homelab-local` berhasil di-import
- [ ] DNS records dibuat di Pi-hole
- [ ] Proxy Host untuk seluruh service dikonfigurasi
- [ ] HTTPS dan Force SSL aktif

---

## Next Step

Setelah NPM berjalan:

1. Setup internal DNS records di Pi-hole
2. Generate dan install SSL self-signed wildcard
3. Deploy service berikutnya

Referensi:

- `pihole-dns-records.md`
- `ssl-self-signed.md`

---

*Last updated: 2026-06-18*