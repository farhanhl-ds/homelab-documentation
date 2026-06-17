# LXC 102 — Security

LXC 102 merupakan container yang menjalankan layanan keamanan dan secret management dalam environment homelab.

LXC ini harus dideploy sebelum LXC 103 dan service berikutnya agar seluruh credential, password, API key, dan secret yang dihasilkan selama proses setup dapat langsung disimpan secara terpusat di Vaultwarden.

## Container Information

| Component | Details |
|---|---|
| CT ID | 102 |
| Hostname | `security` |
| Operating System | Ubuntu 24.04 LTS |
| CPU Allocation | 1 core |
| Memory | 256MB RAM + 256MB Swap |
| Storage | 4GB (`local-lvm`) |
| Container Type | Unprivileged LXC |
| Docker Support | Nesting enabled |

## Network Configuration

| Configuration | Value |
|---|---|
| IP Address | `192.168.100.102/24` |
| Gateway | `192.168.100.1` |
| DNS Server | `192.168.100.101` (Pi-hole) |
| Search Domain | `homelab.local` |

DNS dan akses HTTPS untuk Vaultwarden bergantung pada layanan yang disediakan oleh LXC 101 — Core Infrastructure.

---

## Service Architecture

LXC 102 menyediakan security layer untuk penyimpanan credential dan secret dalam environment homelab.

```text
        LXC 102 — Security
                 |
          Security Layer
                 |
            Vaultwarden
```

## Hosted Services

| Service | Role | Documentation |
|---|---|---|
| Vaultwarden | Password manager dan secret storage | `Services/vaultwarden.md` |

## Dependency Relationship

### Depends On

- LXC 101 — Core Infrastructure
  - Pi-hole untuk internal DNS resolution
  - Nginx Proxy Manager untuk HTTPS reverse proxy

### Required By

- LXC 103 — Database (database password dan credential)
- LXC 104 — Authentication (secret key dan application credential)
- LXC 105 — Productivity (API key dan service credential)
- Homelab administrator untuk password dan secret management

LXC 102 memiliki startup priority setelah LXC 101 karena membutuhkan DNS dan reverse proxy yang disediakan oleh core infrastructure.

## Related Runbooks

- `Runbooks/lxc-base-setup.md` — Initial LXC setup, package update, Docker installation, dan base configuration.
- `Runbooks/vaultwarden-deployment.md` — Vaultwarden deployment, initial setup, dan account creation.

---

*Last updated: 2026-06-17*