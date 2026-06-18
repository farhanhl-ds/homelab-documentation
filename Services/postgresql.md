# PostgreSQL

PostgreSQL menyediakan relational database server sebagai persistent data storage untuk berbagai application service dalam environment homelab.

PostgreSQL menjadi source of truth untuk application data yang membutuhkan konsistensi, transaksi, dan penyimpanan jangka panjang.

## Service Information

| Component | Details |
|---|---|
| Service | PostgreSQL |
| Deployment | Docker Container |
| Host Node | LXC 103 — Database |
| Version | PostgreSQL 16 |
| Internal Port | 5432 |
| External Access | Internal network only |

## Purpose

PostgreSQL digunakan untuk menyimpan data aplikasi yang bersifat persistent.

Contoh penggunaan:

- Authentik — user, group, policy, dan configuration data
- Outline — document, user, dan workspace data
- Postiz — social media management data
- Umami — analytics data
- Future applications yang membutuhkan relational database

PostgreSQL tidak diekspos langsung ke internet dan hanya dapat diakses oleh service internal dalam jaringan homelab.

---

## Connection Model

Service lain mengakses PostgreSQL melalui internal network:

```text
Application Container
          |
          |
192.168.100.103:5432
          |
          |
     PostgreSQL
```

Format koneksi:

```text
postgresql://username:password@192.168.100.103:5432/database_name
```

Credential setiap database disimpan secara terpusat di Vaultwarden.

---

## Database Provisioning Policy

Setiap aplikasi mendapatkan database dan database user yang terpisah.

Contoh:

| Application | Database | User |
|---|---|---|
| Authentik | `db_authentik` | `authentik_user` |
| Outline | `db_outline` | `outline_user` |
| Postiz | `db_postiz` | `postiz_user` |
| Umami | `db_umami` | `umami_user` |

Penggunaan satu database atau satu user bersama untuk banyak aplikasi tidak direkomendasikan karena mengurangi isolasi dan prinsip least privilege.

---

## Data Storage

Data PostgreSQL disimpan secara persistent pada:

```text
/opt/stacks/database/pgdata/
```

Direktori ini berisi:

- Database files
- Table data
- Index
- Transaction logs
- Database metadata

Direktori data merupakan aset kritikal dan wajib dimasukkan dalam proses backup.

---

## Security Model

### Credential Management

Password PostgreSQL tidak disimpan langsung dalam `docker-compose.yml`.

Credential disimpan melalui:

- `.env` file pada deployment
- Vaultwarden sebagai permanent secret storage

### Network Exposure

PostgreSQL hanya menerima koneksi dari internal network homelab.

Tidak ada port forwarding atau public exposure ke internet.

---

## Dependencies

### Depends On

- Docker Engine pada LXC 103
- Persistent storage pada LXC 103
- Vaultwarden untuk penyimpanan credential database

### Required By

- LXC 104 — Authentication (Authentik database)
- LXC 105 — Productivity (Outline, Umami, Postiz, dan aplikasi lain)
- Service masa depan yang membutuhkan relational database

Kegagalan PostgreSQL dapat menyebabkan application service yang bergantung padanya gagal beroperasi.

---

## Backup Requirement

PostgreSQL merupakan salah satu data paling penting dalam homelab.

Backup harus mempertimbangkan:

- Konsistensi database
- Integritas data hasil backup
- Kemampuan melakukan restore

Backup PostgreSQL harus dilakukan secara berkala sebelum melakukan upgrade besar atau perubahan konfigurasi.

---

## Related Runbooks

- `Runbooks/postgresql-deployment.md` — Deployment PostgreSQL, initial database provisioning, dan credential setup.
- `Runbooks/postgresql-maintenance.md` — Update, backup, restore, dan database administration.

---

*Last updated: 2026-06-17*