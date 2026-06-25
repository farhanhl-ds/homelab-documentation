# LXC 105 — Productivity

LXC 105 merupakan application layer dalam environment homelab yang menjalankan berbagai service produktivitas untuk kebutuhan dokumentasi, file utility, dan social media management.

LXC ini dideploy setelah LXC 103 — Database dan LXC 104 — Authentication karena beberapa aplikasi membutuhkan PostgreSQL, Redis, dan Single Sign-On (SSO) melalui Authentik.

## Container Information

| Component | Details |
|---|---|
| CT ID | 105 |
| Hostname | `productivity` |
| Operating System | Ubuntu 24.04 LTS |
| CPU Allocation | 2 cores |
| Memory | 1024MB RAM + 512MB Swap |
| Storage | 16GB (`local-lvm`) |
| Container Type | Unprivileged LXC |
| Docker Support | Nesting enabled |

## Network Configuration

| Configuration | Value |
|---|---|
| IP Address | `192.168.100.105/24` |
| Gateway | `192.168.100.1` |
| DNS Server | `192.168.100.101` (Pi-hole) |
| Search Domain | `homelab.local` |

Akses aplikasi dilakukan melalui HTTPS menggunakan reverse proxy dari LXC 101 — Core Infrastructure.

---

## Hosted Services

| Service | Function | Status | Documentation |
|---|---|---|---|
| Outline | Knowledge base dan internal documentation | ✅ Running | `Services/outline.md` |
| Stirling PDF | PDF tools dan document processing | 🔲 Planned | `Services/stirling-pdf.md` |
| Postiz | Social media management dan scheduler | 🔲 Planned | `Services/postiz.md` |

---

## Dependency Relationship

### Depends On

#### LXC 101 — Core Infrastructure

- Pi-hole untuk internal DNS resolution
- Nginx Proxy Manager untuk HTTPS reverse proxy

#### LXC 102 — Security

- Vaultwarden untuk penyimpanan:
  - Database credential
  - Application secret
  - API key
  - OIDC client secret

#### LXC 103 — Database

- PostgreSQL untuk persistent application data
- Redis untuk:
  - Outline cache/session (`DB 0`)
  - Postiz cache/session (`DB 1`)

#### LXC 104 — Authentication

- Authentik sebagai Identity Provider (IdP)
- Single Sign-On (SSO) menggunakan OIDC

---

## Required By

- Homelab administrator sebagai pengguna utama seluruh productivity service
- Future users yang mendapatkan akses melalui Authentik

Kegagalan LXC 105 tidak memengaruhi layanan infrastructure seperti DNS, database, maupun authentication, tetapi menyebabkan aplikasi produktivitas tidak dapat digunakan.

---

## Application Access Flow

Akses aplikasi mengikuti alur berikut:

```text
User Browser
      |
      v
Nginx Proxy Manager
      |
      v
Application (LXC 105)
      |
      ├── Authentik (OIDC SSO)
      |
      ├── PostgreSQL (Data Storage)
      |
      └── Redis (Cache / Session)
```

---

## Related Runbooks

- `Runbooks/lxc-base-setup.md` — Initial LXC setup, package update, Docker installation, dan base configuration.
- `Runbooks/outline-deployment.md` — Outline deployment, OIDC integration, dan database configuration.
- `Runbooks/stirling-pdf-deployment.md` — Stirling PDF deployment dan configuration.
- `Runbooks/postiz-deployment.md` — Postiz deployment, database configuration, dan Authentik integration.

---

*Last updated: 2026-06-18*