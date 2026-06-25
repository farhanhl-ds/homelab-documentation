# Authentik

Authentik menyediakan centralized identity management, Single Sign-On (SSO), dan Identity Provider (IdP) untuk seluruh service dalam environment homelab.

Authentik menjadi pusat proses authentication dan authorization menggunakan standar OpenID Connect (OIDC), OAuth2, dan SAML.

## Service Information

| Component | Details |
|---|---|
| Service | Authentik |
| Deployment | Docker Container |
| Host Node | LXC 104 — Authentication |
| Access URL | https://auth.homelab.local |
| Admin Interface | https://auth.homelab.local/if/admin/ |
| Internal Port | 9000 |
| Protocol | OIDC, OAuth2, SAML |

---

## Purpose

Authentik digunakan untuk menyediakan identity layer yang terpusat.

Fungsi utama:

- Single Sign-On (SSO) untuk aplikasi internal
- Centralized user management
- Authentication dan authorization policy
- Identity federation menggunakan standar modern
- Mengurangi kebutuhan account terpisah di setiap aplikasi

Aplikasi yang terintegrasi dengan Authentik tidak perlu menyimpan credential user secara lokal.

---

## Access Model

Alur akses aplikasi menggunakan Authentik:

```text
User
 │
 ▼
Application
 │
 ▼
Authentik
 │
 ├── PostgreSQL
 │     └── User, group, policy, dan configuration data
 │
 └── Redis
       └── Session dan cache data
```

Semua komunikasi user dilakukan melalui HTTPS menggunakan reverse proxy dari Nginx Proxy Manager.

---

## Domain & Branding Policy

Authentik menggunakan domain utama:

```
auth.homelab.local
```

Konfigurasi Brand pada Authentik harus menggunakan domain yang sama agar redirect URL, login flow, dan OIDC callback berjalan dengan benar.

---

## OIDC Application Inventory

Daftar aplikasi yang menggunakan Authentik sebagai Identity Provider.

| Application | Protocol | Status |
|---|---|---|
| Outline | OIDC | ✅ Configured |
| Postiz | OIDC | 🔲 Planned |
| Future applications | OIDC/OAuth2/SAML | 🔲 Available |

OIDC Client ID dan Client Secret untuk setiap aplikasi harus disimpan di Vaultwarden.

---

## Reverse Proxy Trust Model

Authentik berada di belakang Nginx Proxy Manager.

Reverse proxy dari network internal `192.168.100.0/24` dipercaya untuk mengirimkan `X-Forwarded-*` header.

Konfigurasi trusted proxy diperlukan agar:

- URL generation berjalan benar
- Redirect menggunakan HTTPS
- Client IP diteruskan dengan benar
- Interface tidak mengalami rendering issue saat diakses melalui reverse proxy

---

## Security Considerations

### Secret Management

Informasi sensitif berikut harus disimpan di Vaultwarden:

- Authentik Secret Key
- Database credential
- Redis password
- OIDC Client ID dan Client Secret

---

### Administrator Account Protection

Administrator memiliki akses penuh terhadap seluruh identity infrastructure.

Disarankan untuk mengaktifkan:

- Two-Factor Authentication (2FA)
- Password yang kuat dan unik
- Backup recovery code di lokasi yang aman

---

## Known Configuration Pitfalls

### Jangan menggunakan `AUTHENTIK_HOST` atau `AUTHENTIK_HOST_BROWSER`

Pada deployment menggunakan Nginx Proxy Manager, environment variable tersebut tidak digunakan.

Menambahkan konfigurasi tersebut dapat menyebabkan:

- Authentication redirect loop
- Masalah URL generation
- Login flow yang tidak berjalan dengan benar

---

## Dependencies

### Depends On

- LXC 101 — Core Infrastructure
  - DNS resolution melalui Pi-hole
  - HTTPS reverse proxy melalui Nginx Proxy Manager

- LXC 102 — Security
  - Vaultwarden untuk secret management

- LXC 103 — Database
  - PostgreSQL untuk identity data
  - Redis untuk cache dan session

---

### Required By

- Outline sebagai OIDC client
- Postiz dan aplikasi lain yang menggunakan Single Sign-On

Kegagalan Authentik tidak menyebabkan database atau aplikasi berhenti berjalan, tetapi proses login dan authentication untuk aplikasi yang bergantung pada SSO akan terganggu.

---

## Backup Requirement

Data Authentik bergantung pada beberapa komponen:

- PostgreSQL database (`db_authentik`)
- Media directory
- Secret key dan credential yang tersimpan di Vaultwarden

Backup harus memastikan seluruh komponen tersebut dapat direstore secara konsisten.

---

## Related Runbooks

- `Runbooks/authentik-deployment.md` — Deployment, initial setup, dan database connection.
- `Runbooks/authentik-proxy-setup.md` — Nginx Proxy Manager dan trusted proxy configuration.
- `Runbooks/authentik-oidc-provider-setup.md` — Pembuatan OIDC provider dan aplikasi baru.
- `Runbooks/authentik-maintenance.md` — Update, backup, dan security maintenance.

---

*Last updated: 2026-06-17*