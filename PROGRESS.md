# Homelab Progress & Session Log

File ini digunakan untuk tracking progress deployment homelab. Diperbarui setiap kali terdapat progress signifikan.

---

## Current State (2026-06-15)

### Sudah Selesai ✅

**LXC 101 — core-infra (192.168.100.101)**
- Docker terinstall
- Semua service running: Portainer, Pihole, NPM, Homepage, Uptime Kuma
- Pihole `listeningMode` diubah ke `ALL` (fix DNS dari LAN)
- DNS records + CNAME records sudah dikonfigurasi di Pihole untuk semua domain `.homelab.local`
- SSL self-signed wildcard `*.homelab.local` sudah di-generate dan di-upload ke NPM
- Semua proxy hosts sudah dikonfigurasi di NPM dengan HTTPS
- Homepage `HOMEPAGE_ALLOWED_HOSTS` sudah diset via environment variable
- VS Code Remote SSH sudah dikonfigurasi dari desktop Windows ke LXC ini

**LXC 102 — security (192.168.100.102)**
- Docker terinstall
- Vaultwarden running dan fully functional
- `DOMAIN` diset ke `https://vault.homelab.local`
- SSL via NPM sudah aktif (cert `homelab-local`)
- Akun pertama sudah dibuat
- `SIGNUPS_ALLOWED` dikembalikan ke `false`
- Bitwarden extension terinstall di Chrome, pointing ke `https://vault.homelab.local`
- Password dari Chrome sudah di-import ke Vaultwarden

**LXC 103 — database (192.168.100.103)**
- PostgreSQL 16 + Redis + Adminer running
- Semua database terbuat: `db_authentik`, `db_outline`, `db_postiz`, `db_umami`
- Password menggunakan `.env` file (tidak hardcode di docker-compose)
- Password `outline_user` diganti ke hex-only (tanpa special characters) — tersimpan di Vaultwarden
- Redis password diganti ke hex-only — tersimpan di Vaultwarden
- Adminer accessible di `https://adminer.homelab.local`

**LXC 104 — auth (192.168.100.104)**
- Authentik server + worker running
- Permission media folder diperbaiki: `chown -R 1000:1000 ./media ./custom-templates ./certs`
- Admin account (`akadmin`) dibuat via initial-setup
- Brands domain diset ke `auth.homelab.local`
- `AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS=192.168.100.0/24` dikonfigurasi di `.env`
- NPM proxy host dengan Custom Nginx Config (X-Forwarded headers) — wajib agar UI render dengan benar
- OIDC provider `outline-provider` dibuat, Client ID & Secret tersimpan di Vaultwarden
- Application `Outline` (slug: `outline`) dibuat dan linked ke provider

**LXC 105 — productivity (192.168.100.105)**
- Outline running dan accessible di `https://outline.homelab.local`
- Login via Authentik SSO berhasil
- `dns: 192.168.100.101` dikonfigurasi di docker-compose agar container dapat resolve `auth.homelab.local`
- `NODE_TLS_REJECT_UNAUTHORIZED: "0"` dikonfigurasi untuk trust self-signed cert
- `OIDC_AUTH_URI` menggunakan endpoint yang benar: `https://auth.homelab.local/application/o/authorize/`

**Network & Infrastructure**
- DNS laptop: IPv6 disabled di adapter Wi-Fi, IPv4 DNS → `192.168.100.101`
- Semua domain `*.homelab.local` sudah resolve via Pihole
- SSL self-signed cert (`homelab.crt` + `homelab.key`) tersimpan di `/opt/stacks/npm/` di LXC 101
- File cert juga tersimpan di `C:\Users\Farhan\Downloads\` di laptop

---

### Belum Selesai 🔲

| LXC / VM | Services | Status |
|---|---|---|
| LXC 105 — productivity | Stirling PDF | 🔲 Pending |
| LXC 105 — productivity | Postiz | 🔲 Pending |
| VM 100 — HAOS | Home Assistant | 🔲 Pending |
| Network | Tailscale | 🔲 Pending |

---

### Next Steps

1. **Deploy Stirling PDF** di LXC 105
2. **Deploy Postiz** di LXC 105
3. **Setup VM 100 — Home Assistant**
4. **Setup Tailscale** — remote access dari luar jaringan

---

## Konfigurasi Penting

### SSH Config (`C:\Users\Farhan\.ssh\config`)

```
Host core-infra
    HostName 192.168.100.101
    User root
    IdentityFile ~/.ssh/id_ed25519

Host security
    HostName 192.168.100.102
    User root
    IdentityFile ~/.ssh/id_ed25519

Host database
    HostName 192.168.100.103
    User root
    IdentityFile ~/.ssh/id_ed25519

Host auth
    HostName 192.168.100.104
    User root
    IdentityFile ~/.ssh/id_ed25519

Host productivity
    HostName 192.168.100.105
    User root
    IdentityFile ~/.ssh/id_ed25519
```

### SSL Certificate
- Di server: `/opt/stacks/npm/homelab.crt` dan `/opt/stacks/npm/homelab.key` (LXC 101)
- Di laptop: `C:\Users\Farhan\Downloads\homelab.crt` dan `homelab.key`
- Valid 10 tahun (expire ~2036), wildcard `*.homelab.local`

### Vaultwarden Admin
- URL: `https://vault.homelab.local/admin`
- Token: tersimpan di docker-compose `/opt/stacks/vaultwarden/docker-compose.yml` di LXC 102

### DNS Windows (Laptop)
- IPv6: disabled di adapter Wi-Fi
- IPv4 DNS: `192.168.100.101` (Pihole), alternate `1.1.1.1`
- Command untuk re-apply apabila reset:
  ```powershell
  Set-DnsClientServerAddress -InterfaceIndex 19 -ServerAddresses ("192.168.100.101","1.1.1.1")
  ```

---

## Known Issues

| Issue | Priority | Catatan |
|---|---|---|
| `ADMIN_TOKEN` Vaultwarden masih plain text | Low | Perlu di-hash menggunakan Argon2 |
| SMTP Vaultwarden belum dikonfigurasi | Low | Invite user harus manual via `SIGNUPS_ALLOWED` sementara |
| Uptime Kuma belum dikonfigurasi monitors | Low | — |
| Homepage belum dikonfigurasi widgets | Low | — |

---

## Session Log

### 2026-06-14
- Setup VS Code Remote SSH ke LXC 101 (core-infra)
- Debug DNS `.homelab.local` — root cause: Windows IPv6 + Pihole `listeningMode LOCAL`
- Setup SSL self-signed wildcard `*.homelab.local`
- Deploy dan setup Vaultwarden di LXC 102
- Import passwords Chrome → Vaultwarden
- Setup Bitwarden extension pointing ke self-hosted

### 2026-06-15
- Deploy LXC 104 — Authentik (fix permission media, Redis password, trusted proxy CIDRs)
- Setup NPM proxy host Authentik dengan Custom Nginx Config
- Deploy LXC 105 — Outline, fully working via SSO Authentik
- Fix: special characters di password, ENOTFOUND DNS, self-signed cert, OIDC auth URI
- Outline accessible di `https://outline.homelab.local`

---

*Last updated: 2026-06-17*