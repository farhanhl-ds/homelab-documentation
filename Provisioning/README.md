# Provisioning

## Purpose

Folder ini berisi executable definitions yang digunakan untuk membangun kembali Homelab secara konsisten dan reproducible.

Provisioning merupakan domain terpisah dari Knowledge Base.

Knowledge Base menjelaskan desain, keputusan arsitektur, konfigurasi, prosedur operasional, dan troubleshooting.

Provisioning berisi code yang digunakan untuk membangun dan mengelola environment secara otomatis.

---

## Goals

Provisioning digunakan untuk:

* Mengurangi konfigurasi manual.
* Meningkatkan konsistensi deployment.
* Menghindari configuration drift.
* Mempercepat proses recovery.
* Mempermudah rebuild environment.
* Menjadikan Homelab reproducible melalui code.

---

## Scope

Provisioning mencakup dua domain utama:

### Infrastructure as Code (IaC)

Membangun resource infrastructure yang menjadi fondasi Homelab.

Contoh:

* Proxmox resources
* LXC containers
* Virtual machines
* Network configuration
* Storage allocation

Infrastructure layer bertanggung jawab untuk menyediakan environment tempat service dijalankan.

---

### Service as Code (SaC)

Mengonfigurasi node dan mendeploy service yang berjalan di atas infrastructure.

Contoh:

* Operating system configuration
* Docker installation
* System hardening
* Service deployment
* Environment configuration
* Service lifecycle management

Service layer bertanggung jawab untuk menghasilkan Homelab yang siap digunakan.

---

## Design Principles

### Documentation First

Provisioning harus mengikuti dokumentasi yang terdapat pada Knowledge Base.

Knowledge Base tetap menjadi sumber kebenaran utama mengenai desain dan operasional Homelab.

---

### Reproducibility

Provisioning harus mampu menghasilkan environment yang konsisten setiap kali dijalankan.

Target utama project ini adalah kemampuan untuk membangun kembali Homelab dari kondisi kosong dengan proses yang terdefinisi dan dapat diulang.

---

### Idempotency

Provisioning harus aman dijalankan berulang kali tanpa menghasilkan perubahan yang tidak diperlukan.

---

### Version Controlled

Seluruh provisioning code harus disimpan dalam Git dan dikelola menggunakan version control.

---

### Incremental Automation

Automation diterapkan secara bertahap.

Prioritas diberikan pada proses yang:

* Berulang
* Memakan waktu
* Rentan terhadap human error
* Dibutuhkan dalam proses recovery

---

## Planned Structure

```text
Provisioning
│
├── README.md
│
├── IaC
│   └── terraform
│
└── SaC
    └── ansible
```

Struktur dapat berkembang seiring bertambahnya kebutuhan Homelab.

---

## Candidate Technologies

| Domain                 | Candidate Tool              |
| ---------------------- | --------------------------- |
| Infrastructure as Code | Terraform                   |
| Service as Code        | Ansible                     |
| Secrets Management     | Vaultwarden + Ansible Vault |
| Container Runtime      | Docker                      |
| Service Deployment     | Docker Compose              |
| CI/CD                  | To Be Determined            |

Pemilihan tool akan didokumentasikan melalui ADR apabila telah menjadi keputusan resmi.

---

## Roadmap

### Phase 1 — Foundation

* Define provisioning architecture
* Define repository structure
* Define secrets strategy

---

### Phase 2 — Infrastructure as Code

* Proxmox provisioning
* LXC provisioning
* Network provisioning

---

### Phase 3 — Service as Code

* Base OS configuration
* Docker installation
* Node standardization
* Security baseline

---

### Phase 4 — Service Deployment

* Automated deployment of Homelab services
* Environment configuration management
* Standardized deployment templates

---

### Phase 5 — Recovery and Lifecycle Management

* Rebuild workflows
* Secret rotation workflows
* Backup integration
* Maintenance automation

---

## Vision

A Homelab that can be rebuilt from code.

Manual installation is limited to:

1. Install Proxmox.
2. Restore access to repositories and secrets.

Everything else should be reproducible through Provisioning.

---

*Last updated: 2026-06*
