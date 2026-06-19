# Docker Networking Architecture

Panduan arsitektur networking Docker yang digunakan pada seluruh LXC homelab.

---

## Overview

Setiap LXC menjalankan Docker secara independen.

Masing-masing LXC memiliki:

- IP address sendiri
- Docker daemon sendiri
- Docker bridge network sendiri

Contoh:

```text
Proxmox Host
      |
      |
      +--------------------------------+
      |                                |
      v                                v

LXC 101                          LXC 105
192.168.100.101                  192.168.100.105

Docker Engine                    Docker Engine
      |                                |
docker0                          docker0
172.17.0.0/16                    172.17.0.0/16
      |                                |
Containers                       Containers
```

> Meskipun subnet Docker sama (`172.17.0.0/16`), tidak terjadi konflik karena setiap Docker bridge hanya berlaku di dalam namespace network LXC masing-masing.

---

## Network Layers

Arsitektur network terdiri dari tiga layer:

```text
Layer 1:
Physical Network / LAN
192.168.100.0/24

        ↓

Layer 2:
LXC Network
192.168.100.101 - 192.168.100.105

        ↓

Layer 3:
Docker Bridge
172.17.0.0/16
```

---

# Container Communication

## Communication inside the same LXC

Container dalam LXC yang sama dapat berkomunikasi menggunakan:

### Docker Service Name

Contoh:

```
postgres
redis
adminer
```

Pada docker-compose:

```yaml
services:
  app:
    environment:
      DATABASE_HOST: postgres
```

Docker internal DNS akan melakukan resolusi otomatis.

---

## Communication between different LXC

Container tidak boleh menggunakan Docker IP.

Contoh yang salah:

```
postgres://user:password@172.17.0.2:5432/database
```

Karena:

- Docker IP dapat berubah saat container recreate
- Tidak dapat diakses dari LXC lain
- Docker bridge terisolasi

Gunakan IP LXC:

```
postgres://user:password@192.168.100.103:5432/database
```

Contoh nyata:

### Authentik

LXC:

```
192.168.100.104
```

Mengakses:

PostgreSQL:

```
192.168.100.103:5432
```

Redis:

```
192.168.100.103:6379
```

---

## Port Mapping Philosophy

Semua service yang perlu diakses dari luar container harus menggunakan port mapping.

Format:

```
HOST_PORT:CONTAINER_PORT
```

Contoh:

### Outline

```yaml
ports:
  - "3000:3000"
```

Akses:

```
192.168.100.105:3000
```

---

### Postiz

```yaml
ports:
  - "3001:3000"
```

Karena port 3000 sudah digunakan oleh Outline pada LXC yang sama.

---

## DNS Inside Container

Beberapa aplikasi perlu melakukan DNS lookup ke domain internal:

Contoh:

```
auth.homelab.local
```

Agar menggunakan Pihole, tambahkan:

```yaml
dns:
  - 192.168.100.101
```

Contoh nyata:

```yaml
services:
  outline:
    dns:
      - 192.168.100.101
```

Tanpa konfigurasi ini, OIDC ke Authentik dapat gagal dengan:

```
ENOTFOUND auth.homelab.local
```

---

# Why We Don't Use Custom Docker Networks

Untuk homelab ini, default Docker bridge sudah cukup.

Keuntungan:

- Konfigurasi sederhana
- Mudah troubleshooting
- Tidak perlu maintain network tambahan
- Compatible dengan semua Docker Compose

Custom network dipertimbangkan apabila:

- Banyak container dalam satu LXC
- Perlu network isolation
- Menggunakan multi-tier application yang kompleks

---

# Network Troubleshooting

## Check Docker Networks

Lihat network yang tersedia:

```bash
docker network ls
```

Detail network:

```bash
docker network inspect bridge
```

---

## Check Container IP

```bash
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_name
```

---

## Test Connectivity

### Test dari LXC

Contoh ke database:

```bash
nc -zv 192.168.100.103 5432
```

Expected:

```
Connection successful
```

---

### Test DNS Resolution

Dari dalam container:

```bash
docker exec -it container_name sh
```

Kemudian:

```bash
nslookup auth.homelab.local
```

Expected:

```
192.168.100.101
```

---

## Common Mistakes

### Menggunakan Docker IP antar LXC

❌ Salah:

```
172.17.x.x
```

✅ Benar:

```
192.168.100.x
```

---

### Tidak expose port

Jika service harus diakses dari LXC lain:

Pastikan ada:

```yaml
ports:
  - "host:container"
```

---

### Menganggap semua Docker network saling terhubung

Tidak benar.

Setiap LXC memiliki Docker network sendiri.

---

## Security Notes

- Jangan expose port yang tidak diperlukan.
- Database dan Redis tetap menggunakan private LAN, bukan internet.
- Semua akses user menggunakan Nginx Proxy Manager.
- Gunakan firewall atau Tailscale untuk akses remote.

---

## Related Documents

- `database-deployment.md`
- `authentik-deployment.md`
- `outline-deployment.md`
- `pihole-dns-records.md`
- `npm-proxy-host.md`

---

*Last updated: 2026-06-19*