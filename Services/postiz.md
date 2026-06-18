# Postiz

Postiz merupakan self-hosted social media management platform yang digunakan untuk membuat, menjadwalkan, dan mengelola konten pada berbagai platform sosial media dari satu dashboard terpusat.

Postiz dirancang sebagai application service yang menyimpan data secara lokal di environment homelab.

## Service Information

| Component | Details |
|---|---|
| Service | Postiz |
| Deployment | Docker Container |
| Host Node | LXC 105 — Productivity |
| Access URL | https://postiz.homelab.local |
| Internal Port | 3001 |
| Authentication | Local account (SSO planned) |

---

## Purpose

Postiz digunakan untuk:

- Menjadwalkan posting social media
- Mengelola beberapa account social media dari satu dashboard
- Menyimpan draft dan media asset
- Mengatur publishing workflow

---

## Data Architecture

Postiz menggunakan beberapa komponen eksternal:

| Component | Usage |
|---|---|
| PostgreSQL | Persistent data (`db_postiz`) |
| Redis | Cache, session, dan background job (`DB 1`) |
| Local Storage | Media upload dan application files |

Data upload disimpan pada volume:

```text
/opt/stacks/postiz/uploads/
```

---

## Access Model

Akses Postiz dilakukan melalui HTTPS menggunakan reverse proxy dari Nginx Proxy Manager.

```text
User Browser
      |
      v
Nginx Proxy Manager
      |
      v
Postiz
      |
      ├── PostgreSQL
      │       └── Posts, settings, dan application data
      │
      └── Redis
              └── Cache, session, dan background jobs
```

---

## HTTPS Requirement

Postiz harus dikonfigurasi menggunakan HTTPS domain sejak deployment pertama.

Environment seperti:

```text
NEXT_PUBLIC_BACKEND_URL=https://postiz.homelab.local
FRONTEND_URL=https://postiz.homelab.local
```

harus menggunakan URL final berbasis HTTPS.

Menggunakan HTTP saat initial setup kemudian mengubahnya ke HTTPS dapat menyebabkan:

- Redirect loop
- Invalid session
- Authentication issue

---

## Social Media Credential Management

Credential untuk integrasi social media seperti:

- API key
- Client secret
- Access token
- Refresh token

merupakan data sensitif dan harus disimpan secara aman.

Vaultwarden digunakan sebagai tempat penyimpanan:

- Social media API credential
- Application secret
- Database credential

---

## Authentication Model

Saat ini Postiz menggunakan authentication internal.

Integrasi dengan Authentik menggunakan OIDC direncanakan pada fase berikutnya untuk menyediakan:

- Single Sign-On (SSO)
- Centralized user management
- Unified authentication experience

---

## Dependency Relationship

### Depends On

- LXC 101 — Core Infrastructure
  - Pi-hole untuk DNS resolution
  - Nginx Proxy Manager untuk HTTPS access

- LXC 102 — Security
  - Vaultwarden untuk penyimpanan:
    - Database credential
    - Application secret
    - Social media API credential

- LXC 103 — Database
  - PostgreSQL (`db_postiz`)
  - Redis (`DB 1`)

### Required By

- Homelab administrator untuk melakukan social media management

Kegagalan Postiz tidak memengaruhi service lain dalam homelab.

---

## Backup Requirement

Backup Postiz harus mencakup:

- PostgreSQL database `db_postiz`
- Upload directory `/opt/stacks/postiz/uploads`
- Application secret
- Social media API credential yang tersimpan di Vaultwarden

Ketiga komponen tersebut diperlukan untuk melakukan full restore.

---

## Future Improvement

Rencana pengembangan berikutnya:

- Integrasi OIDC dengan Authentik
- Multi-user access management
- Backup automation
- Monitoring menggunakan Uptime Kuma

---

## Related Runbooks

- `Runbooks/postiz-deployment.md` — Deployment, database configuration, dan initial setup.
- `Runbooks/postiz-authentication.md` — Integrasi OIDC dengan Authentik.
- `Runbooks/postiz-maintenance.md` — Update, backup, dan maintenance.

---

*Last updated: 2026-06-18*