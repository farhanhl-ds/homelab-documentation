# Vaultwarden

Vaultwarden menyediakan password management dan centralized secret storage untuk seluruh environment homelab.

Vaultwarden menjadi source of truth untuk seluruh credential, password, API key, dan secret yang digunakan oleh service internal.

## Service Information

| Component | Details |
|---|---|
| Service | Vaultwarden |
| Deployment | Docker Container |
| Host Node | LXC 102 — Security |
| URL | https://vault.homelab.local |
| Admin Panel | https://vault.homelab.local/admin |
| Internal Port | 80 |

## Purpose

Vaultwarden digunakan untuk menyimpan dan mengelola seluruh informasi sensitif dalam homelab.

Contoh data yang disimpan:

- Password administrator
- Database credential
- Application secret key
- API token
- SMTP credential
- SSL certificate information
- Recovery code dan emergency access information

Vaultwarden merupakan fondasi security layer dan sebaiknya tersedia sebelum melakukan deployment service lain.

---

## Access Model

### User Access

User mengakses Vaultwarden melalui HTTPS yang disediakan oleh Nginx Proxy Manager:

```
https://vault.homelab.local
```

### Administrator Access

Administrative operation dilakukan melalui:

```
https://vault.homelab.local/admin
```

Admin panel digunakan untuk:
- Melakukan administrative configuration
- Mengelola kebijakan pendaftaran akun
- Melakukan maintenance tertentu

---

## Security Policies

### Account Registration Policy

Public signup dinonaktifkan secara default.

Pembuatan akun baru hanya dapat dilakukan oleh administrator melalui proses yang terkontrol.

### Admin Token Protection

Akses admin panel dilindungi menggunakan `ADMIN_TOKEN`.

Untuk meningkatkan keamanan, admin token sebaiknya menggunakan hash Argon2 dibandingkan plain text.

### Multi-Factor Authentication (Planned)

Two-factor authentication (2FA) direkomendasikan untuk seluruh akun yang memiliki akses ke Vaultwarden.

Status implementasi saat ini:

- [ ] Enable 2FA untuk akun utama

---

## Data Storage

Data persistent Vaultwarden disimpan pada:

```
/opt/stacks/vaultwarden/data/
```

Data yang disimpan meliputi:

- User account
- Vault data
- Encrypted password database
- Organization data
- Attachment
- Configuration data

Direktori ini merupakan data kritikal dan wajib disertakan dalam proses backup.

---

## Dependencies

### Depends On

- Docker Engine pada LXC 102
- LXC 101 — Core Infrastructure:
  - Pi-hole untuk DNS resolution
  - Nginx Proxy Manager untuk HTTPS access

### Required By

- Seluruh service dalam homelab yang menggunakan credential, password, atau secret key
- Homelab administrator untuk credential management

Kehilangan Vaultwarden tidak menghentikan service yang sudah berjalan, namun dapat menghambat proses maintenance, recovery, dan deployment service baru.

---

## Backup Requirement

Vaultwarden menyimpan data dengan tingkat sensitivitas tertinggi dalam homelab.

Backup harus mempertimbangkan:

- Kerahasiaan data backup
- Integritas data backup
- Kemampuan melakukan restore ketika terjadi failure

Backup Vaultwarden sebaiknya dilakukan secara berkala dan disimpan pada lokasi yang aman.

---

## Related Runbooks

- `Runbooks/vaultwarden-deployment.md` — Initial deployment, account creation, dan password import.
- `Runbooks/vaultwarden-maintenance.md` — Update, backup, restore, dan security maintenance.

---

*Last updated: 2026-06-17*