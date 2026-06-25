# Runbooks

Dokumen ini berisi prosedur operasional untuk melakukan deployment, konfigurasi, maintenance, dan troubleshooting seluruh environment homelab.

Gunakan runbook ini sebagai panduan ketika melakukan:

- Initial deployment
- Rebuild environment dari nol
- Menambahkan service baru
- Maintenance rutin
- Troubleshooting masalah operasional

---

# Homelab Deployment Order

Deployment dilakukan berdasarkan dependency antar component.

## Phase 0 — Proxmox Installation

Persiapan hypervisor dan hardware.

Checklist:

- [ ] Install Proxmox VE
- [ ] Konfigurasi network management
- [ ] Set hostname `haytham.homelab.local`
- [ ] Verifikasi IP `192.168.100.10`
- [ ] Konfigurasi storage
- [ ] Konfigurasi auto update policy

Referensi:

- `Infrastructure/proxmox.md`
- `Infrastructure/hardware.md`

---

## Phase 1 — Base LXC Preparation

Buat seluruh LXC sesuai perencanaan.

LXC yang dibuat:

| ID | Hostname | Role |
|---|---|---|
| 101 | core-infra | Core Infrastructure |
| 102 | security | Security Services |
| 103 | database | Shared Database |
| 104 | auth | Identity Provider |
| 105 | productivity | User Applications |

Checklist:

- [ ] Create LXC
- [ ] Configure CPU, RAM, disk, dan network
- [ ] Enable unprivileged container
- [ ] Enable nesting untuk Docker
- [ ] Configure DNS dan search domain
- [ ] Update package system

Runbook:

- `Deployment/create-lxc.md`

---

## Phase 2 — Docker Runtime Installation

Install Docker pada seluruh LXC yang menjalankan application container.

Target:

- LXC 101
- LXC 102
- LXC 103
- LXC 104
- LXC 105

Checklist:

- [ ] Install Docker Engine
- [ ] Install Docker Compose plugin
- [ ] Verifikasi `docker ps`
- [ ] Buat struktur `/opt/stacks`

Runbook:

- `Deployment/docker-installation.md`

---

## Phase 3 — Core Infrastructure Deployment

Dependency paling dasar yang dibutuhkan service lain.

Target:

LXC 101 — Core Infrastructure

Deployment order:

1. Pi-hole
2. Nginx Proxy Manager
3. SSL Certificate
4. Internal DNS Record
5. Portainer
6. Homepage
7. Uptime Kuma

Checklist:

- [ ] Deploy Pi-hole
- [ ] Disable systemd-resolved
- [ ] Configure DNS upstream
- [ ] Deploy Nginx Proxy Manager
- [ ] Generate self-signed wildcard certificate
- [ ] Configure HTTPS proxy host
- [ ] Create DNS A/CNAME records
- [ ] Deploy Portainer
- [ ] Deploy Homepage
- [ ] Deploy Uptime Kuma
- [ ] Verify internal domain access

Runbooks:

- `Deployment/pihole-deployment.md`
- `Deployment/nginx-proxy-manager-deployment.md`
- `Configuration/ssl-self-signed.md`
- `Configuration/pihole-dns-records.md`
- `Configuration/npm-proxy-host.md`

---

## Phase 4 — Security Layer

LXC 102 — Security

Deployment:

1. Vaultwarden

Checklist:

- [ ] Deploy Vaultwarden
- [ ] Create first administrator account
- [ ] Disable public signup
- [ ] Import existing credential
- [ ] Configure browser extension

Runbook:

- `Deployment/vaultwarden-deployment.md`

---

## Phase 5 — Database Layer

LXC 103 — Database

Deployment:

1. PostgreSQL
2. Redis
3. Adminer

Checklist:

- [ ] Generate database password
- [ ] Store credential in Vaultwarden
- [ ] Create PostgreSQL databases
- [ ] Configure Redis authentication
- [ ] Deploy Adminer
- [ ] Verify database connectivity

Runbook:

- `Deployment/database-deployment.md`

---

## Phase 6 — Identity & Authentication

LXC 104 — Authentication

Deployment:

1. Authentik
2. Initial administrator setup
3. Reverse proxy configuration

Checklist:

- [ ] Generate Authentik secret key
- [ ] Configure PostgreSQL connection
- [ ] Configure Redis connection
- [ ] Deploy Authentik
- [ ] Complete initial setup
- [ ] Configure NPM proxy
- [ ] Configure Authentik brand

Runbooks:

- `Deployment/authentik-deployment.md`
- `Configuration/authentik-oidc.md`

---

## Phase 7 — Productivity Applications

LXC 105 — Productivity

Deployment order:

1. Outline
2. Stirling PDF
3. Postiz

Checklist:

### Outline

- [ ] Generate application secrets
- [ ] Configure database connection
- [ ] Configure Redis connection
- [ ] Configure OIDC integration
- [ ] Deploy Outline
- [ ] Verify SSO login

### Stirling PDF

- [ ] Deploy container
- [ ] Configure NPM proxy
- [ ] Verify HTTPS access

### Postiz

- [ ] Configure database connection
- [ ] Configure Redis connection
- [ ] Generate JWT secret
- [ ] Deploy Postiz
- [ ] Configure HTTPS domain
- [ ] Configure social media integration

Runbooks:

- `Deployment/outline-deployment.md`
- `Deployment/stirling-pdf-deployment.md`
- `Deployment/postiz-deployment.md`

---

## Phase 8 — Remote Access

Configure secure remote access melalui Tailscale.

Checklist:

- [ ] Install Tailscale di Proxmox host
- [ ] Configure subnet router
- [ ] Approve route di Tailscale admin console
- [ ] Verify remote access ke seluruh service

Referensi:

- `Infrastructure/tailscale.md`

---

## Phase 9 — Operations & Maintenance

Setelah seluruh service berjalan, lakukan konfigurasi operasional.

Target:

- Backup strategy
- Update procedure
- Monitoring
- Health check
- Disaster recovery

Runbooks:

- `Operations/backup-restore.md`
- `Operations/update-service.md`
- `Operations/health-check.md`

---

## Phase 10 — Troubleshooting

Apabila terjadi masalah operasional.

Kategori:

- DNS issue
- Docker issue
- Certificate issue
- Database issue
- Authentication issue
- Network issue

Runbooks:

- `Troubleshooting/`

---

# Recovery Philosophy

Homelab harus dapat dibangun ulang hanya menggunakan:

1. Repository dokumentasi ini
2. Backup data dan configuration
3. Vaultwarden untuk seluruh secret dan credential

Apabila seluruh prosedur dan backup tersedia, seluruh environment dapat direcovery tanpa mengandalkan ingatan manual.

---

# Related Documentation

Untuk memahami arsitektur sebelum melakukan deployment:

- `README.md`
- `Architecture/architecture-overview.md`
- `Architecture/decisions.md`
- `Infrastructure/`
- `Nodes/`
- `Services/`

---

*Last updated: 2026-06-18*