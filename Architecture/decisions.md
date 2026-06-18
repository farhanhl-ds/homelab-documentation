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

# Future ADR

Keputusan berikut dapat ditambahkan di masa depan:

- Backup strategy dan retention policy.
- Monitoring dan alerting strategy.
- High availability dan clustering.
- Storage migration.
- Public service exposure apabila diperlukan.

---

*Last updated: 2026-06-18*