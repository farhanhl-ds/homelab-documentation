# Homelab Progress & Session Log

High-level dashboard untuk tracking status homelab, progress dokumentasi, dan milestone project.

Dokumentasi teknis detail tersedia pada folder `Infrastructure`, `Nodes`, `Services`, dan `Runbooks`.

---

# Project Status

## Infrastructure

| Component | Status |
|---|---|
| Proxmox Host | ✅ Completed |
| Network & DNS | ✅ Completed |
| SSL Self-Signed Certificate | ✅ Completed |
| Docker Environment | ✅ Completed |
| Backup Strategy | ✅ Documented |

---

## Services

| Service | Status |
|---|---|
| Pi-hole | ✅ Running |
| Nginx Proxy Manager | ✅ Running |
| Homepage | ✅ Running |
| Uptime Kuma | 🟡 Running — Monitoring belum dikonfigurasi penuh |
| Portainer | ✅ Running |
| Vaultwarden | 🟡 Running — Security hardening masih diperlukan |
| PostgreSQL | ✅ Running |
| Redis | ✅ Running |
| Adminer | ✅ Running |
| Authentik | ✅ Running |
| Outline | ✅ Running (SSO Authentik) |
| Stirling PDF | ✅ Running |
| Postiz | ✅ Running |
| Home Assistant | 🔲 Pending Deployment |
| Tailscale | 🔲 Pending Configuration |

---

# LXC & VM Status

| Node | Role | Status |
|---|---|---|
| LXC 101 | Core Infrastructure | ✅ Production |
| LXC 102 | Security | ✅ Production |
| LXC 103 | Database | ✅ Production |
| LXC 104 | Authentication | ✅ Production |
| LXC 105 | Productivity | ✅ Production |
| VM 100 | Home Assistant OS | 🔲 Not Configured |

---

# Documentation Status

| Category | Status |
|---|---|
| Architecture | ✅ Completed |
| Infrastructure | ✅ Completed |
| Nodes | ✅ Completed |
| Services | ✅ Completed |
| Runbooks — Deployment | ✅ Completed |
| Runbooks — Configuration | ✅ Completed |
| Runbooks — Administration | ✅ Completed |
| Runbooks — Operations | ✅ Completed |
| Runbooks — Troubleshooting | 🔥 In Progress (Final Boss) |

---

# Current Priorities

## High Priority

- Complete `Runbooks/Troubleshooting`
- Deploy and configure Home Assistant VM
- Configure Tailscale remote access

---

## Medium Priority

- Configure Uptime Kuma monitors
- Configure Homepage widgets
- Implement Vaultwarden `ADMIN_TOKEN` Argon2 hash
- Configure SMTP untuk Vaultwarden

---

## Low Priority

- Review backup automation
- Review update schedule
- Improve service monitoring dashboard

---

# Important Quick References

## SSH Access

SSH host aliases sudah dikonfigurasi pada:

```text
C:\Users\Farhan\.ssh\config
```

---

## SSL Certificate

Wildcard certificate:

```text
*.homelab.local
```

Lokasi:

Server:
```text
/opt/stacks/npm/homelab.crt
/opt/stacks/npm/homelab.key
```

Laptop:
```text
C:\Users\Farhan\Downloads\
```

---

## Windows DNS Recovery

Apabila konfigurasi DNS Windows ter-reset:

```powershell
Set-DnsClientServerAddress `
  -InterfaceIndex 19 `
  -ServerAddresses ("192.168.100.101", "1.1.1.1")
```

---

# Known Issues & Improvements

| Item | Priority | Status |
|---|---|---|
| Vaultwarden `ADMIN_TOKEN` masih plain text | Low | Pending |
| SMTP Vaultwarden belum dikonfigurasi | Low | Pending |
| Uptime Kuma monitor belum dibuat | Medium | Pending |
| Homepage widgets belum dikonfigurasi | Medium | Pending |
| Home Assistant belum dikonfigurasi | High | Pending |
| Tailscale belum dikonfigurasi | High | Pending |

---

# Session Log

## 2026-06-14 — Foundation Phase

- Setup VS Code Remote SSH
- Debug DNS `.homelab.local`
- Fix Pi-hole listening mode
- Disable Windows IPv6 untuk menghindari DNS conflict
- Generate SSL wildcard `*.homelab.local`
- Deploy Vaultwarden
- Migrasi password Chrome ke Vaultwarden

---

## 2026-06-15 — Identity & Knowledge Base Phase

- Deploy Authentik
- Fix permission dan trusted proxy configuration
- Configure Authentik melalui Nginx Proxy Manager
- Deploy Outline
- Integrasi SSO menggunakan Authentik OIDC
- Debug OIDC endpoint, DNS resolution, dan self-signed certificate issue

---

## 2026-06-16 — Productivity Expansion Phase

- Deploy Stirling PDF
- Deploy Postiz
- Konfigurasi reverse proxy dan HTTPS endpoint

---

## 2026-06-17 — Documentation Consolidation Phase

- Membuat struktur dokumentasi repository:
  - Architecture
  - Infrastructure
  - Nodes
  - Services
  - Runbooks
- Memisahkan deployment, configuration, dan operational documentation

---

## 2026-06-18 — Operations & Recovery Phase

- Membuat operational runbooks:
  - Health Check
  - Monitoring
  - Shutdown Procedure
  - Power Recovery
  - Backup & Restore
  - Service Migration

---

## 2026-06-19 — Repository Finalization Phase

- Review konsistensi naming documentation
- Refactor `PROGRESS.md` menjadi project dashboard
- Review seluruh repository structure
- Menyiapkan final extraction untuk troubleshooting documentation

---

# Project Completion

```text
Homelab Infrastructure     ████████████████████ 95%
Documentation Repository   ███████████████████░ 90%
Overall Project            ███████████████████░ 92%
```

---

# Next Milestone

## 🔥 Final Documentation Phase

Complete `Runbooks/Troubleshooting` extraction dari legacy troubleshooting document.

Setelah selesai:

- Documentation repository mencapai tahap production-ready
- Seluruh deployment history telah terdokumentasi
- Operational recovery procedure telah tersedia

---

*"A homelab is not finished when it works. It is finished when future you can fix it at 3 AM without guessing."*

---

*Last updated: 2026-06-19*