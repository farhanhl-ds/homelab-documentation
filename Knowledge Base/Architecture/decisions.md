# Architecture Decisions

Dokumen ini mencatat keputusan arsitektur utama dalam pembangunan homelab beserta alasan, trade-off, dan konsekuensinya.

---

# ADR-001 — Menggunakan Proxmox LXC sebagai Node Utama

## Decision

Service dijalankan menggunakan LXC container di Proxmox dengan Docker sebagai application runtime, bukan membuat satu VM untuk setiap aplikasi.

## Reasoning

- Resource overhead lebih kecil dibanding full virtual machine.
- Startup lebih cepat.
- Isolasi antar service tetap terjaga melalui pemisahan LXC berdasarkan role.
- Mudah melakukan backup dan restore pada level container.

## Trade-off

### Pros

- Efisien untuk hardware terbatas (8GB RAM).
- Manajemen resource lebih mudah.
- Fleksibel untuk menambah service baru.

### Cons

- Isolation lebih rendah dibanding VM.
- Bergantung pada Linux kernel host.
- Beberapa aplikasi mungkin membutuhkan konfigurasi tambahan seperti Docker nesting.

---

# ADR-002 — Memisahkan Service Berdasarkan Role

## Decision

Service tidak ditempatkan dalam satu LXC besar, tetapi dipisahkan berdasarkan tanggung jawab:

- Core Infrastructure
- Security
- Database
- Authentication
- Productivity

## Reasoning

Pemisahan ini membuat dependency lebih jelas dan mengurangi blast radius ketika satu LXC mengalami masalah.

## Trade-off

### Pros

- Architecture lebih modular.
- Resource allocation lebih terkontrol.
- Maintenance dan troubleshooting lebih mudah.

### Cons

- Membutuhkan lebih banyak konfigurasi jaringan.
- Dependency antar LXC perlu dikelola dengan benar.

---

# ADR-003 — Pi-hole Tidak Menggunakan Diri Sendiri sebagai DNS Resolver

## Decision

LXC 101 menggunakan public DNS upstream (Cloudflare/Google) dan tidak mengarah ke Pi-hole yang berjalan pada container yang sama.

## Reasoning

Menggunakan Pi-hole sebagai DNS untuk dirinya sendiri akan menyebabkan circular dependency.

Apabila service Pi-hole gagal berjalan:

- LXC kehilangan DNS resolution.
- Docker image pull dan update dapat gagal.
- Proses troubleshooting menjadi lebih sulit.

## Trade-off

### Pros

- LXC 101 tetap dapat melakukan internet resolution walaupun Pi-hole down.
- Recovery lebih mudah.

### Cons

- DNS request dari LXC 101 tidak melewati filtering Pi-hole.

---

# ADR-004 — Menggunakan Self-Signed Wildcard Certificate

## Decision

Domain internal `*.homelab.local` menggunakan satu wildcard self-signed certificate.

## Reasoning

Homelab tidak memiliki public domain dan tidak membuka port ke internet.

Certificate internal memberikan:
- HTTPS encryption.
- Konsistensi akses menggunakan domain.
- Kemudahan pengelolaan banyak service.

## Trade-off

### Pros

- Satu certificate untuk seluruh service.
- Tidak bergantung pada external CA.
- Tidak membutuhkan DNS challenge atau port forwarding.

### Cons

- Certificate harus di-install manual pada client.
- Tidak dipercaya secara default oleh browser.

---

# ADR-005 — Menggunakan Tailscale untuk Remote Access

## Decision

Remote access menggunakan Tailscale subnet router melalui Proxmox host.

Tidak menggunakan:
- Port forwarding
- Dynamic DNS
- Public reverse proxy

## Reasoning

Akses remote hanya diberikan kepada device yang menjadi anggota tailnet.

## Trade-off

### Pros

- Tidak membuka service ke public internet.
- Tidak perlu mengelola firewall atau port forwarding.
- Access control dilakukan melalui Tailscale.

### Cons

- Device harus memiliki Tailscale client.
- Bergantung pada availability layanan Tailscale.

---

# ADR-006 — Menggunakan Database Terpusat

## Decision

PostgreSQL dan Redis ditempatkan pada LXC khusus yang digunakan oleh banyak aplikasi.

## Reasoning

Database dianggap sebagai shared infrastructure.

Aplikasi seperti:
- Authentik
- Outline
- Postiz

menggunakan infrastruktur database yang sama dengan isolasi melalui database PostgreSQL, user database, dan Redis index yang berbeda.

## Trade-off

### Pros

- Backup database menjadi terpusat.
- Resource database dapat dioptimalkan.
- Mudah menambahkan aplikasi baru.

### Cons

- LXC database menjadi critical dependency.
- Gangguan pada database memengaruhi beberapa service sekaligus.

---

# ADR-007 — Centralized Identity dan Secret Management

## Decision

Authentication dan secret tidak disimpan tersebar di setiap aplikasi.

Menggunakan:
- Authentik untuk identity provider.
- Vaultwarden untuk credential dan secret storage.

## Reasoning

Centralized management mengurangi risiko credential tersebar dan memberikan pengalaman login yang konsisten.

## Trade-off

### Pros

- SSO antar aplikasi.
- Credential management lebih aman.
- Lebih mudah melakukan rotasi secret.

### Cons

- Authentik dan Vaultwarden menjadi service dengan criticality tinggi.

---

# ADR-008 — Memisahkan Documentation dan Automation sebagai Domain Berbeda

## Decision

Dokumentasi dan automation diperlakukan sebagai dua domain yang memiliki tanggung jawab berbeda.

Dokumentasi digunakan untuk menjelaskan desain, alasan keputusan, konfigurasi, prosedur operasional, dan pengalaman troubleshooting.

Automation digunakan sebagai representasi executable untuk membangun dan mengelola infrastructure serta services secara otomatis.

## Reasoning

Dokumentasi dan automation memiliki tujuan yang berbeda:

Dokumentasi membantu manusia memahami sistem.
Automation membantu mesin membangun dan mengelola sistem.

Memisahkan kedua domain mencegah dokumentasi berubah menjadi sekadar kumpulan script, serta menjaga automation tetap fokus pada reproducible execution.

## Trade-off

### Pros
Knowledge dan executable code memiliki batas tanggung jawab yang jelas.
Dokumentasi tetap menjadi sumber informasi utama.
Automation dapat berevolusi tanpa mengubah struktur dokumentasi.
Mempermudah pengembangan AI-based knowledge system di masa depan.

### Cons
Informasi dapat tersebar antara dokumentasi dan automation.
Membutuhkan disiplin untuk menjaga keduanya tetap sinkron.

---

# ADR-009 — Memisahkan Identitas Service dan Lokasi Node

## Decision

Service dan Node diperlakukan sebagai entitas yang berbeda.

Service mendefinisikan apa yang berjalan.

Node mendefinisikan di mana workload tersebut berjalan.

Contoh:
```
Service:
- Outline

Node:
- LXC 105 - Productivity
```

## Reasoning

Lokasi sebuah service dapat berubah seiring perkembangan infrastructure.

Contoh:
- Service berpindah ke LXC baru.
- Service dipindahkan ke VM.
- Service dijalankan menggunakan platform yang berbeda.

Dengan pemisahan ini, dokumentasi service tetap konsisten walaupun lokasi deployment berubah.

## Trade-off

### Pros
- Dokumentasi lebih modular.
- Migrasi workload menjadi lebih mudah.
- Mengurangi coupling antara aplikasi dan infrastructure.

### Cons
- Membutuhkan dokumentasi dependency antara service dan node.

---

# ADR-010 — Documentation sebagai Foundation untuk Agentic Knowledge System

## Decision

Seluruh dokumentasi Homelab dirancang sebagai structured knowledge yang dapat digunakan oleh manusia maupun AI system.

Dokumentasi bukan hanya arsip, tetapi menjadi sumber informasi operasional yang dapat di-query, dianalisis, dan digunakan untuk membantu pengambilan keputusan.

## Reasoning

Seiring bertambahnya kompleksitas Homelab, pencarian informasi manual menjadi semakin sulit.

Dengan struktur dokumentasi yang konsisten, knowledge dapat digunakan sebagai dasar untuk:

- Semantic search.
- Retrieval-Augmented Generation (RAG).
- AI assistant untuk troubleshooting.
- Automation recommendation dan operational guidance.

## Trade-off

### Pros
- Knowledge menjadi reusable.
- Historical incident dapat digunakan kembali untuk troubleshooting.
- Mempercepat proses pencarian informasi.
- Menjadi fondasi pengembangan AI assistant Homelab.

### Cons
- Membutuhkan konsistensi format dokumentasi.
- Membutuhkan effort tambahan untuk menjaga kualitas knowledge.

---

# ADR-011 — Memisahkan Human Secret Store dan Automation Secret Store

## Decision

Vaultwarden digunakan sebagai source of truth untuk seluruh credential dan secret Homelab.

Ansible Vault digunakan sebagai automation secret store untuk kebutuhan Infrastructure as Code dan Service as Code.

## Reasoning

Vaultwarden dan Ansible Vault menyelesaikan masalah yang berbeda.

Vaultwarden berfungsi sebagai penyimpanan secret jangka panjang yang dikelola manusia.

Ansible Vault berfungsi sebagai penyimpanan secret yang dikonsumsi automation workflow.

## Trade-off

### Pros
- Tidak perlu menambah secret management service baru.
- Integrasi native dengan Ansible.
- Tetap memiliki source of truth yang jelas.
- Mendukung automation tanpa meningkatkan kompleksitas secara signifikan.

### Cons
- Secret tersimpan di dua lokasi.
- Membutuhkan sinkronisasi saat rotasi credential.

---

# ADR-012 — Terraform sebagai Infrastructure Source of Truth

## Decision

Terraform digunakan sebagai source of truth untuk seluruh Infrastructure Layer Homelab.

Infrastructure didefinisikan sebagai resource yang berada pada level Proxmox, meliputi:

* LXC
* Virtual Machine
* CPU Allocation
* Memory Allocation
* Disk Allocation
* Network Configuration
* IP Address
* DNS Configuration
* SSH Key Injection
* Metadata dan Tagging

Setiap node direpresentasikan sebagai file Terraform terpisah yang mengikuti struktur dokumentasi Node yang sudah ada.

Repository automation dipisahkan dari repository dokumentasi.

## Reasoning

Tujuan utama Infrastructure as Code adalah memungkinkan Homelab dibangun kembali secara konsisten setelah terjadi kegagalan perangkat atau disaster recovery scenario.

Dengan menjadikan Terraform sebagai source of truth, seluruh node dapat direproduksi menggunakan blueprint yang tersimpan di version control.

Pendekatan ini mengurangi ketergantungan pada konfigurasi manual di Proxmox dan memastikan infrastruktur dapat dibangun ulang dengan proses yang terdokumentasi.

Terraform bertanggung jawab pada provisioning infrastructure.

Konfigurasi sistem operasi, package installation, Docker setup, hardening, dan deployment aplikasi akan dikelola oleh Ansible sebagai layer berikutnya.

Repository automation dipisahkan dari repository dokumentasi karena keduanya memiliki lifecycle dan tanggung jawab yang berbeda.

## Trade-off

### Pros

* Infrastructure dapat direbuild secara konsisten setelah disaster.
* Konfigurasi infrastructure tersimpan di version control.
* Mengurangi konfigurasi manual pada Proxmox.
* Perubahan infrastructure menjadi lebih mudah dilacak.
* Struktur Terraform mengikuti struktur dokumentasi Node yang sudah ada.
* Automation dapat berkembang tanpa memengaruhi struktur Knowledge Base.

### Cons

* Membutuhkan effort awal untuk mengimplementasikan Terraform.
* Dokumentasi dan automation harus dijaga tetap sinkron.
* Menambah kompleksitas dibanding konfigurasi manual.
* Terraform state menjadi komponen penting yang harus dikelola dan dibackup dengan baik.

---

# Future ADR

Keputusan berikut dapat ditambahkan di masa depan:

- Monitoring dan alerting strategy.
- Backup retention dan off-site backup strategy.
- Secret management automation.
- Infrastructure as Code implementation strategy.
- Service deployment automation strategy.
- High availability dan clustering.
- Storage migration.
- Public service exposure apabila diperlukan.

---

*Last updated: 2026-06-18*