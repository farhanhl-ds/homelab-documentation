# Network Setup — Step 8

Panduan setup DNS records di Pihole, proxy hosts di NPM, dan routing semua service via domain `*.homelab.local`. Dilakukan setelah semua LXC dan service running.

> **Prasyarat:** LXC 101 (Pihole + NPM) harus sudah running sebelum mulai step ini.

---

## Domain Convention

Semua service accessible via subdomain `.homelab.local`:

| Service | Domain | Forward ke |
|---|---|---|
| Portainer | portainer.homelab.local | 192.168.100.101:9000 |
| Pihole | pihole.homelab.local | 192.168.100.101:8080 |
| NPM | npm.homelab.local | 192.168.100.101:81 |
| Homepage | homepage.homelab.local | 192.168.100.101:3000 |
| Uptime Kuma | uptime.homelab.local | 192.168.100.101:3001 |
| Vaultwarden | vault.homelab.local | 192.168.100.102:8080 |
| Adminer | adminer.homelab.local | 192.168.100.103:8080 |
| Authentik | auth.homelab.local | 192.168.100.104:9000 |
| Outline | outline.homelab.local | 192.168.100.105:3000 |
| Stirling PDF | stirling.homelab.local | 192.168.100.105:8080 |
| Postiz | postiz.homelab.local | 192.168.100.106:3000 |
| Home Assistant | ha.homelab.local | 192.168.100.100:8123 |

---

## Flow DNS + Proxy

```
Device ketik vault.homelab.local
         ↓
Pihole resolve → 192.168.100.101 (IP NPM)
         ↓
NPM terima request, cek domain "vault.homelab.local"
         ↓
NPM forward ke 192.168.100.102:8080 (Vaultwarden)
         ↓
Vaultwarden served via HTTPS
```

Semua domain `.homelab.local` resolve ke **IP NPM (192.168.100.101)** — NPM yang handle routing ke service yang tepat.

---

## Step 1 — Setup SSL Certificate di NPM

Karena pakai `.homelab.local` (internal domain, bukan public), kita pakai **self-signed certificate** di NPM.

1. Buka NPM: `http://192.168.100.101:81`
2. **SSL Certificates** → **Add SSL Certificate** → pilih **Custom**
3. Isi:
   - Name: `homelab-local`
4. Klik **Save**

> **Alternatif:** Bisa juga generate self-signed cert per domain, atau pakai wildcard `*.homelab.local`. Untuk simplicity, kita generate per proxy host saat setup masing-masing.

---

## Step 2 — Setup DNS Records di Pihole

Semua domain `.homelab.local` harus resolve ke IP NPM (192.168.100.101).

1. Buka Pihole: `http://192.168.100.101:8080/admin`
2. Login dengan password yang di-set di docker-compose
3. **Local DNS** → **DNS Records**
4. Tambah satu per satu:

| Domain | IP |
|---|---|
| portainer.homelab.local | 192.168.100.101 |
| pihole.homelab.local | 192.168.100.101 |
| npm.homelab.local | 192.168.100.101 |
| homepage.homelab.local | 192.168.100.101 |
| uptime.homelab.local | 192.168.100.101 |
| vault.homelab.local | 192.168.100.101 |
| adminer.homelab.local | 192.168.100.101 |
| auth.homelab.local | 192.168.100.101 |
| outline.homelab.local | 192.168.100.101 |
| stirling.homelab.local | 192.168.100.101 |
| postiz.homelab.local | 192.168.100.101 |
| ha.homelab.local | 192.168.100.101 |

Klik **Add** setelah isi tiap baris.

---

## Step 3 — Setup Proxy Hosts di NPM

Untuk tiap service, tambah proxy host di NPM. Langkah per proxy host:

1. **Proxy Hosts** → **Add Proxy Host**
2. Tab **Details** — isi domain, forward host, dan port
3. Tab **SSL** — pilih certificate, enable **Force SSL**
4. Klik **Save**

### Vaultwarden

| Field | Value |
|---|---|
| Domain | vault.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.102 |
| Forward Port | 8080 |
| Force SSL | ✅ |
| Websockets Support | ✅ |

> **Kenapa Websockets:** Vaultwarden butuh websocket untuk live sync antar device.

---

### Portainer

| Field | Value |
|---|---|
| Domain | portainer.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.101 |
| Forward Port | 9000 |
| Force SSL | ✅ |
| Websockets Support | ✅ |

---

### Pihole

| Field | Value |
|---|---|
| Domain | pihole.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.101 |
| Forward Port | 8080 |
| Force SSL | ✅ |
| Websockets Support | ❌ |

---

### NPM

| Field | Value |
|---|---|
| Domain | npm.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.101 |
| Forward Port | 81 |
| Force SSL | ✅ |
| Websockets Support | ❌ |

---

### Homepage

| Field | Value |
|---|---|
| Domain | homepage.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.101 |
| Forward Port | 3000 |
| Force SSL | ✅ |
| Websockets Support | ✅ |

> **Setelah setup:** Update `HOMEPAGE_ALLOWED_HOSTS` di docker-compose Homepage:
> ```yaml
> HOMEPAGE_ALLOWED_HOSTS: "homepage.homelab.local"
> ```
> Lalu `docker compose up -d --force-recreate`

---

### Uptime Kuma

| Field | Value |
|---|---|
| Domain | uptime.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.101 |
| Forward Port | 3001 |
| Force SSL | ✅ |
| Websockets Support | ✅ |

---

### Adminer

| Field | Value |
|---|---|
| Domain | adminer.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.103 |
| Forward Port | 8080 |
| Force SSL | ✅ |
| Websockets Support | ❌ |

---

### Authentik

| Field | Value |
|---|---|
| Domain | auth.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.104 |
| Forward Port | 9000 |
| Force SSL | ✅ |
| Websockets Support | ✅ |

---

### Outline

| Field | Value |
|---|---|
| Domain | outline.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.105 |
| Forward Port | 3000 |
| Force SSL | ✅ |
| Websockets Support | ✅ |

> **Setelah setup:** Update `URL` di docker-compose Outline:
> ```yaml
> URL: "https://outline.homelab.local"
> FORCE_HTTPS: "true"
> ```
> Dan update OIDC redirect URI di Authentik ke `https://outline.homelab.local/auth/oidc.callback`

---

### Stirling PDF

| Field | Value |
|---|---|
| Domain | stirling.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.105 |
| Forward Port | 8080 |
| Force SSL | ✅ |
| Websockets Support | ❌ |

---

### Postiz

| Field | Value |
|---|---|
| Domain | postiz.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.106 |
| Forward Port | 3000 |
| Force SSL | ✅ |
| Websockets Support | ✅ |

> **Setelah setup:** Update env di docker-compose Postiz:
> ```yaml
> NEXT_PUBLIC_BACKEND_URL: "https://postiz.homelab.local"
> FRONTEND_URL: "https://postiz.homelab.local"
> ```

---

### Home Assistant

| Field | Value |
|---|---|
| Domain | ha.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.100 |
| Forward Port | 8123 |
| Force SSL | ✅ |
| Websockets Support | ✅ |

> **Setelah setup:** Tambah trusted proxy di HAOS config (`configuration.yaml`):
> ```yaml
> http:
>   use_x_forwarded_for: true
>   trusted_proxies:
>     - 192.168.100.101
> ```

---

## Step 4 — Set Pihole sebagai DNS di Router IndiHome

Setelah semua DNS records dan proxy hosts dikonfigurasi:

1. Buka admin panel router IndiHome
2. Cari setting **DHCP** atau **DNS**
3. Set **Primary DNS** ke `192.168.100.101` (Pihole)
4. Set **Secondary DNS** ke `1.1.1.1` (fallback kalau Pihole down)
5. Save dan restart router

Setelah ini, semua device di network yang dapat IP dari router akan otomatis pakai Pihole sebagai DNS — dan bisa akses semua domain `.homelab.local`.

> **Catatan:** Device yang sudah connect sebelumnya perlu reconnect atau renew IP untuk dapat DNS baru. Di Windows: `ipconfig /flushdns && ipconfig /release && ipconfig /renew`. Di Mac/Linux: reconnect WiFi.

---

## Step 5 — Setup Tailscale (Remote Access)

Lihat **infrastructure/tailscale.md** untuk panduan install Tailscale di Proxmox host sebagai subnet router — untuk akses homelab dari luar network IndiHome.

---

## Post-Setup Checklist

- [ ] Semua DNS records terdaftar di Pihole
- [ ] Semua proxy hosts terdaftar di NPM
- [ ] Semua domain `.homelab.local` accessible via HTTPS
- [ ] Vaultwarden accessible via `https://vault.homelab.local`
- [ ] Router IndiHome DNS diset ke Pihole
- [ ] `HOMEPAGE_ALLOWED_HOSTS` diupdate ke domain
- [ ] Outline `URL` diupdate ke HTTPS domain
- [ ] Postiz URLs diupdate ke HTTPS domain
- [ ] HAOS trusted proxy dikonfigurasi
- [ ] Tailscale setup (opsional)

## Known Issues / Notes

- Self-signed certificate akan trigger warning "Not secure" di browser — ini normal untuk internal homelab. Klik **Advanced** → **Proceed** untuk lanjut.
- Kalau ada service yang tidak bisa diakses via domain setelah setup, cek urutan: DNS record di Pihole → proxy host di NPM → service running di LXC-nya.
- DNS LXC 101 tetap di 1.1.1.1 — jangan diganti ke Pihole (circular dependency).

## Last Updated

2026-06-14
