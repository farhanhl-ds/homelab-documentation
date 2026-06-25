# LXC 103 — Database

LXC 103 merupakan container yang menyediakan data layer untuk seluruh environment homelab melalui layanan PostgreSQL, Redis, dan database administration tool.

LXC ini sebaiknya dideploy setelah LXC 102 — Security agar seluruh database credential, Redis password, dan secret lain yang dihasilkan selama proses setup dapat langsung disimpan secara terpusat di Vaultwarden.

## Container Information

| Component | Details |
|---|---|
| CT ID | 103 |
| Hostname | `database` |
| Operating System | Ubuntu 24.04 LTS |
| CPU Allocation | 2 cores |
| Memory | 1024MB RAM + 512MB Swap |
| Storage | 16GB (`local-lvm`) |
| Container Type | Unprivileged LXC |
| Docker Support | Nesting enabled |

## Network Configuration

| Configuration | Value |
|---|---|
| IP Address | `192.168.100.103/24` |
| Gateway | `192.168.100.1` |
| DNS Server | `192.168.100.101` (Pi-hole) |
| Search Domain | `homelab.local` |

Akses HTTPS untuk database administration menggunakan layanan reverse proxy yang disediakan oleh LXC 101 — Core Infrastructure.

---

## Service Architecture

LXC 103 menyediakan data layer yang terdiri dari database server, in-memory datastore, dan administration interface.

```text
          LXC 103 — Database
                    |
               Data Layer
                    |
        ┌───────────┼───────────┐
        |           |           |
   PostgreSQL      Redis      Adminer
        |           |           |
 Persistent      Cache &     Database
   Storage       Session    Administration
```

Setiap service memiliki tanggung jawab yang berbeda:

| Layer | Service | Responsibility |
|---|---|---|
| Database | PostgreSQL | Relational database untuk persistent application data |
| Cache | Redis | In-memory datastore untuk cache, session, dan temporary data |
| Administration | Adminer | Web interface untuk database management dan verification |

## Hosted Services

| Service | Role | Documentation |
|---|---|---|
| PostgreSQL | Relational database server | `Services/postgresql.md` |
| Redis | In-memory datastore dan cache | `Services/redis.md` |
| Adminer | Database administration interface | `Services/adminer.md` |

## Dependency Relationship

### Depends On

- LXC 101 — Core Infrastructure
  - Pi-hole untuk internal DNS resolution
  - Nginx Proxy Manager untuk HTTPS access ke Adminer

- LXC 102 — Security
  - Vaultwarden untuk penyimpanan database credential dan secret

### Required By

- LXC 104 — Authentication
  - PostgreSQL untuk Authentik database
  - Redis untuk cache dan session storage

- LXC 105 — Productivity
  - PostgreSQL dan Redis untuk aplikasi yang membutuhkan data storage

- Database administrator melalui Adminer untuk database management dan troubleshooting

LXC 103 memiliki startup priority setelah LXC 102 karena database credential dan secret management harus tersedia sebelum provisioning database baru.

## Related Runbooks

- `Runbooks/lxc-base-setup.md` — Initial LXC setup, package update, Docker installation, dan base configuration.
- `Runbooks/postgresql-deployment.md` — PostgreSQL deployment dan initial database provisioning.
- `Runbooks/redis-deployment.md` — Redis deployment dan password configuration.
- `Runbooks/adminer-deployment.md` — Adminer deployment dan initial access configuration.

---

*Last updated: 2026-06-17*