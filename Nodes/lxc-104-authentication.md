# LXC 104 — Authentication

LXC 104 merupakan container yang menyediakan identity layer untuk environment homelab melalui layanan Authentik sebagai Identity Provider (IdP) dan Single Sign-On (SSO) provider.

LXC ini harus dideploy setelah LXC 103 — Database karena Authentik membutuhkan PostgreSQL sebagai persistent data storage dan Redis untuk cache serta session management.

## Container Information

| Component | Details |
|---|---|
| CT ID | 104 |
| Hostname | `auth` |
| Operating System | Ubuntu 24.04 LTS |
| CPU Allocation | 2 cores |
| Memory | 2048MB RAM + 1024MB Swap |
| Storage | 16GB (`local-lvm`) |
| Container Type | Unprivileged LXC |
| Docker Support | Nesting enabled |

## Network Configuration

| Configuration | Value |
|---|---|
| IP Address | `192.168.100.104/24` |
| Gateway | `192.168.100.1` |
| DNS Server | `192.168.100.101` (Pi-hole) |
| Search Domain | `homelab.local` |

Akses HTTPS ke Authentik menggunakan reverse proxy yang disediakan oleh LXC 101 — Core Infrastructure.

---

## Service Architecture

LXC 104 menyediakan centralized identity management untuk seluruh aplikasi homelab.

```text
              LXC 104 — Authentication
                          |
                   Identity Layer
                          |
                      Authentik
                          |
                    OIDC / SSO
                          |
             ┌────────────┴────────────┐
             |                         |
          Outline                   Postiz
```

Authentik bertindak sebagai pusat authentication dan authorization untuk aplikasi yang mendukung protokol OpenID Connect (OIDC).

## Hosted Services

| Service | Role | Documentation |
|---|---|---|
| Authentik | Identity Provider (IdP), SSO, dan OIDC provider | `Services/authentik.md` |

## Dependency Relationship

### Depends On

- LXC 101 — Core Infrastructure
  - Pi-hole untuk internal DNS resolution
  - Nginx Proxy Manager untuk HTTPS reverse proxy

- LXC 102 — Security
  - Vaultwarden untuk penyimpanan credential database, secret key, dan OIDC client secret

- LXC 103 — Database
  - PostgreSQL sebagai persistent data storage (`db_authentik`)
  - Redis sebagai cache dan session storage (Redis DB index `2`)

### Required By

- LXC 105 — Productivity
  - Application yang menggunakan Single Sign-On (SSO) melalui Authentik

- Future applications
  - Service lain yang mendukung OIDC, OAuth2, atau SAML authentication

- Homelab administrator
  - Centralized user, identity, dan access management

LXC 104 memiliki startup priority setelah LXC 103 karena identity service tidak dapat berjalan tanpa database dan cache layer yang tersedia.

---

## Authentication Flow

Alur akses aplikasi yang menggunakan Authentik:

```text
User
 │
 ▼
Application
 │
 ▼
Authentik (OIDC)
 │
 ├── PostgreSQL (Identity Data)
 │
 └── Redis (Session & Cache)
```

Aplikasi tidak menyimpan credential user secara lokal, tetapi mendelegasikan proses authentication kepada Authentik melalui protokol OIDC.

---

## Related Runbooks

- `Runbooks/lxc-base-setup.md` — Initial LXC setup, package update, Docker installation, dan base configuration.
- `Runbooks/authentik-deployment.md` — Authentik deployment, initial setup, database connection, dan secret configuration.
- `Runbooks/authentik-oidc-setup.md` — OIDC provider dan application integration.

---

*Last updated: 2026-06-17*