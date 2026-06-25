# Homelab Architecture Overview

Dokumen ini memberikan gambaran menyeluruh mengenai hubungan antar node, service, jaringan, authentication, dan dependency dalam homelab.

---

# Physical & Network Topology

```text
Internet
   |
   v
Router (192.168.100.1)
   |
   v
Proxmox Host
haytham (192.168.100.10)
   |
   +----------------------------+
   |                            |
   v                            v
LXC Containers                 VM
                                |
                                +-- Home Assistant OS
```

---

# Node Layout

```text
LXC 101 — Core Infrastructure
|
├── Pi-hole
├── Nginx Proxy Manager
├── Homepage
├── Uptime Kuma
└── Portainer


LXC 102 — Security
|
└── Vaultwarden


LXC 103 — Database
|
├── PostgreSQL
├── Redis
└── Adminer


LXC 104 — Authentication
|
└── Authentik


LXC 105 — Productivity
|
├── Outline
├── Stirling PDF
└── Postiz
```

---

# Service Dependency Graph

```text
                        Vaultwarden
                             |
                             |
                             v
                    Application Secrets
                             |
                             |
                             v

Pi-hole ----> All Services <---- Nginx Proxy Manager
   |
   |
   v
DNS Resolution


PostgreSQL <---------+
                     |
Redis <--------------+------ Outline
                     |
                     +------ Postiz


Authentik
    |
    |
    +------ Outline (OIDC)
    |
    +------ Postiz (planned)
```

---

# Request Flow

## Standard HTTPS Request

```text
User Browser
      |
      v
Nginx Proxy Manager
      |
      v
Application Container
```

Example:

```text
https://outline.homelab.local

Browser
   |
   v
NPM
   |
   v
Outline
```

---

# Authentication Flow (OIDC)

```text
User
 |
 v
Outline
 |
 | Redirect
 v
Authentik
 |
 | Verify identity
 v
User Session
 |
 v
Outline
```

---

# Data Flow

## Outline

```text
Outline
 |
 +-- PostgreSQL
 |       |
 |       +-- Documents & Metadata
 |
 +-- Redis
 |       |
 |       +-- Session & Cache
 |
 +-- Local Storage
         |
         +-- Attachment Files
```

---

## Postiz

```text
Postiz
 |
 +-- PostgreSQL
 |       |
 |       +-- Posts & Configuration
 |
 +-- Redis
 |       |
 |       +-- Queue & Cache
 |
 +-- Local Storage
         |
         +-- Media Uploads
```

---

# Startup Dependency

Setelah Proxmox boot, service startup mengikuti urutan:

```text
Proxmox Host
      |
      v
LXC 101 - Core Infrastructure
      |
      +-- DNS
      +-- Reverse Proxy
      |
      v
LXC 102 - Security
      |
      v
LXC 103 - Database
      |
      v
LXC 104 - Authentication
      |
      v
LXC 105 - Productivity
```

Tujuannya untuk memastikan dependency seperti DNS, database, dan authentication sudah tersedia sebelum aplikasi yang bergantung padanya dijalankan.

---

# Backup Dependency Map

Backup prioritas berdasarkan criticality:

```text
Tier 1 - Critical
|
├── Vaultwarden
│   └── All secrets & credentials
│
├── PostgreSQL
│   └── Application databases
│
└── SSL Certificates


Tier 2 - Important
|
├── Application Uploads
├── Docker Volumes
└── Service Configurations


Tier 3 - Rebuildable
|
└── Container Images
```

---

# Security Model

```text
External Access
       |
       v
Tailscale Tailnet
       |
       v
Internal Network
       |
       +-- HTTPS via Nginx Proxy Manager
       |
       +-- Internal DNS via Pi-hole
       |
       +-- Secrets managed by Vaultwarden
       |
       +-- Identity managed by Authentik
```


# Documentation Architecture

Dokumentasi Homelab dipisahkan berdasarkan domain tanggung jawab agar setiap aspek sistem memiliki sumber informasi yang jelas.

```text
Documentation
|
├── Architecture
├── Infrastructure
├── Nodes
├── Services
├── Runbooks
└── Homelab Knowledge Base
```

Setiap domain memiliki tujuan yang berbeda:

| Domain                 | Responsibility                                                           |
| ---------------------- | ------------------------------------------------------------------------ |
| Architecture           | High-level design, architectural decisions, dan prinsip desain Homelab   |
| Infrastructure         | Dokumentasi hardware, network, backup, dan platform foundation           |
| Nodes                  | Dokumentasi setiap LXC dan Virtual Machine beserta perannya              |
| Services               | Dokumentasi aplikasi, dependency, konfigurasi, dan informasi operasional |
| Runbooks               | Prosedur deployment, configuration, operation, dan troubleshooting       |
| Homelab Knowledge Base | Lessons learned, historical incidents, konsep, dan reference material    |

Dokumentasi menjadi sumber utama untuk memahami alasan desain, konfigurasi yang digunakan, serta pengalaman operasional yang telah terjadi.

---

# Automation Architecture

Automation merupakan domain terpisah yang bertanggung jawab terhadap definisi executable untuk membangun dan mengelola Homelab secara otomatis.

Dokumentasi menjelaskan **mengapa dan bagaimana** sistem dirancang, sedangkan automation menjelaskan **bagaimana sistem dapat dibuat kembali secara konsisten menggunakan code**.

Struktur automation yang direncanakan:

```text
Automation
|
├── Infrastructure
│   └── Terraform
│
├── Configuration
│   └── Ansible
│
├── Services
│   └── Service Definitions
│
└── Pipelines
```

Pendekatan ini memungkinkan:

* Infrastructure as Code menggunakan Terraform.
* Configuration Management menggunakan Ansible.
* Service deployment yang konsisten dan dapat direproduksi.
* Pengurangan konfigurasi manual.
* Pencegahan configuration drift.
* Proses recovery dan rebuild environment yang lebih cepat.

Automation tidak menggantikan dokumentasi yang sudah ada, tetapi menjadi lapisan tambahan yang mengubah proses manual menjadi executable workflow.

---

# Future Development

Arah pengembangan Homelab selanjutnya berfokus pada tiga area utama.

## Infrastructure as Code

Membangun dan mengelola infrastructure menggunakan pendekatan deklaratif agar environment dapat dibuat ulang secara konsisten.

---

## Service as Code

Mengelola deployment dan konfigurasi service menggunakan definisi yang dapat direproduksi, terkontrol melalui version control, dan mudah di-deploy ulang.

---

## Agentic Knowledge System

Memanfaatkan dokumentasi Homelab sebagai sumber knowledge untuk sistem AI berbasis Agentic RAG.

Sistem ini bertujuan untuk:

* Memahami arsitektur dan dependency Homelab.
* Membantu proses troubleshooting berdasarkan historical incidents.
* Memberikan rekomendasi langkah operasional berdasarkan runbooks.
* Menjadi interface pencarian dan analisis terhadap seluruh dokumentasi Homelab.


---

# Design Philosophy

Arsitektur homelab ini dibangun berdasarkan prinsip:

- Separation of concerns antara infrastructure, nodes, services, dan operations.
- Minimal public exposure dengan akses remote melalui Tailscale tanpa port forwarding.
- Centralized identity menggunakan Authentik.
- Centralized secret management menggunakan Vaultwarden.
- Data ownership melalui self-hosted services.
- Recoverability melalui backup dan dokumentasi lengkap.

---

*Last updated: 2026-06-18*