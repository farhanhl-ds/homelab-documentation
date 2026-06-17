LXC 102 menjalankan Vaultwarden sebagai password manager self-hosted untuk seluruh secret key dan credential homelab.

> **Deploy LXC ini sebelum LXC 103 dan seterusnya** — seluruh secret key dan password yang di-generate saat setup database, Authentik, dan service lain harus langsung disimpan di Vaultwarden.

## Specs

| | |
|---|---|
| CT ID | 102 |
| Hostname | security |
| OS | Ubuntu 24.04 LTS |
| CPU | 1 core |
| RAM | 256MB |
| Swap | 256MB |
| Disk | 4GB (local-lvm) |
| Unprivileged | Yes |
| Nesting | Yes (Docker) |

## Network

| | |
|---|---|
| IP | 192.168.100.102/24 |
| Gateway | 192.168.100.1 |
| DNS | 192.168.100.101 |
| Search domain | homelab.local |

> Untuk langkah pembuatan LXC step by step, lihat [create-lxc-guide.md](../runbooks/create-lxc-guide.md).

---

## Services

### Vaultwarden

| | |
|---|---|
| URL | https://vault.homelab.local |
| Admin panel | https://vault.homelab.local/admin |
| Path | /opt/stacks/vaultwarden/ |

#### Generate Admin Token

```bash
openssl rand -base64 48
```

Simpan output di Vaultwarden setelah setup selesai.

#### docker-compose.yml

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    ports:
      - "8080:80"
    environment:
      DOMAIN: "https://vault.homelab.local"
      SIGNUPS_ALLOWED: "false"
      ADMIN_TOKEN: "your_admin_token"
    volumes:
      - ./data:/data

volumes: {}
```

> **Catatan:**
> - `DOMAIN` harus HTTPS dan menggunakan domain yang benar — bukan IP
> - `SIGNUPS_ALLOWED: false` — akun hanya dapat dibuat via admin panel
> - `ADMIN_TOKEN` plain text akan memunculkan warning di admin panel — dapat di-hash menggunakan Argon2 (lihat checklist)

#### Deploy

```bash
cd /opt/stacks/vaultwarden
docker compose up -d
docker compose ps
```

#### Setup Akun Pertama (tanpa SMTP)

Karena SMTP belum dikonfigurasi, invite email tidak dapat dikirim. Workaround:

1. Enable signup sementara: ganti `SIGNUPS_ALLOWED: "false"` → `"true"` → `docker compose up -d --force-recreate`
2. Buka `https://vault.homelab.local` → Create account
3. Disable signup kembali: ganti ke `"false"` → `docker compose up -d --force-recreate`

#### Import Password dari Chrome

1. Chrome → Settings → Password Manager → Export passwords → simpan `.csv`
2. Vaultwarden → Tools → Import → pilih format **Chrome** → upload CSV → Import
3. Hapus file CSV setelah import selesai — file ini berisi password dalam format plaintext

---

## Post-Deploy Checklist

- [x] Vaultwarden accessible di `https://vault.homelab.local`
- [x] Admin panel accessible di `https://vault.homelab.local/admin`
- [x] `DOMAIN` diset ke HTTPS
- [x] Akun pertama dibuat
- [x] `SIGNUPS_ALLOWED` dikembalikan ke `false`
- [x] Password Chrome di-import ke Vaultwarden
- [x] Bitwarden extension terinstall dan pointing ke self-hosted
- [x] SSL via NPM aktif (cert `homelab-local`)
- [ ] Hash `ADMIN_TOKEN` menggunakan Argon2
- [ ] Setup SMTP
- [ ] Enable 2FA
- [ ] Setup backup otomatis

---

*Last updated: 2026-06-16*
