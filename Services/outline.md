# Outline

Outline merupakan knowledge base dan documentation platform yang digunakan sebagai pusat dokumentasi internal homelab.

Outline menggunakan Single Sign-On (SSO) melalui Authentik menggunakan protokol OpenID Connect (OIDC) sehingga credential pengguna tidak disimpan secara lokal pada aplikasi.

## Service Information

| Component | Details |
|---|---|
| Service | Outline |
| Deployment | Docker Container |
| Host Node | LXC 105 — Productivity |
| Access URL | https://outline.homelab.local |
| Internal Port | 3000 |
| Authentication | Authentik OIDC |

---

## Purpose

Outline digunakan untuk:

- Menyimpan dokumentasi teknikal homelab
- Membuat knowledge base pribadi
- Menyimpan prosedur operasional dan catatan teknis
- Menjadi sumber dokumentasi terpusat

---

## Data Architecture

Outline menggunakan beberapa komponen eksternal:

| Component | Usage |
|---|---|
| PostgreSQL | Persistent data (`db_outline`) |
| Redis | Cache dan session (`DB 0`) |
| Local Storage | File attachment dan upload |

Data attachment disimpan pada volume:

```text
/opt/stacks/outline/data/
```

---

## Authentication Model

Outline tidak memiliki local username dan password.

Seluruh proses authentication didelegasikan kepada Authentik melalui OpenID Connect (OIDC).

Authentication flow:

```text
User
 |
 v
Outline
 |
 v
Authentik
 |
 +-- User Identity
```

OIDC Client ID dan Client Secret disimpan di Vaultwarden.

---

## Network & DNS Requirement

Outline perlu dapat melakukan DNS resolution terhadap:

```text
auth.homelab.local
```

karena aplikasi harus melakukan komunikasi dengan Authentik untuk login dan token validation.

Docker container Outline menggunakan Pi-hole sebagai DNS resolver agar domain internal `*.homelab.local` dapat di-resolve dengan benar.

---

## TLS Consideration

Homelab menggunakan self-signed wildcard certificate untuk domain `*.homelab.local`.

Karena koneksi OIDC antara Outline dan Authentik menggunakan certificate self-signed, Node.js TLS verification perlu dinonaktifkan melalui:

```text
NODE_TLS_REJECT_UNAUTHORIZED=0
```

Konfigurasi ini hanya digunakan untuk environment internal homelab dan tidak direkomendasikan untuk public production environment.

---

## Dependency Relationship

### Depends On

- LXC 101 — Core Infrastructure
  - Pi-hole untuk DNS resolution
  - Nginx Proxy Manager untuk HTTPS access

- LXC 102 — Security
  - Vaultwarden untuk menyimpan:
    - OIDC credential
    - Application secret

- LXC 103 — Database
  - PostgreSQL (`db_outline`)
  - Redis (`DB 0`)

- LXC 104 — Authentication
  - Authentik sebagai OIDC provider

---

### Required By

- Homelab administrator untuk membuat dan mengakses dokumentasi

Kegagalan Outline tidak memengaruhi service lain dalam homelab.

---

## Backup Requirement

Backup Outline harus mencakup:

- PostgreSQL database `db_outline`
- Attachment directory `/opt/stacks/outline/data`
- Application secret yang tersimpan di Vaultwarden

Ketiga komponen tersebut diperlukan untuk melakukan full restore.

---

## Related Runbooks

- `Runbooks/outline-deployment.md`
- `Runbooks/outline-oidc-setup.md`
- `Runbooks/outline-maintenance.md`

---

*Last updated: 2026-06-18*