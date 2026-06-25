# Pihole DNS Records Configuration

Panduan konfigurasi DNS records pada Pihole untuk seluruh domain internal homelab.

Pihole bertindak sebagai authoritative DNS untuk domain:

```
homelab.local
```

Semua service akan diakses menggunakan format:

```
service.homelab.local
```

---

## DNS Architecture

```text
                  Client Device
                         |
                    DNS Query
                         |
                         v
              Pihole DNS Server
              192.168.100.101
                         |
               Local DNS Records
                         |
                         v
             Nginx Proxy Manager
             192.168.100.101
                         |
               Reverse Proxy
                         |
         +---------------+---------------+
         |               |               |
     Authentik         Outline        Postiz
     Vaultwarden       Homepage       dll
```

---

## Access Pihole

Buka:

```
https://pihole.homelab.local
```

Login menggunakan administrator password.

Masuk ke:

```
Settings
   ↓
Local DNS Records
```

---

## Create Base Records

Buat record berikut:

### A Record

| Domain | Type | Target |
|---|---|---|
| homelab.local | A | 192.168.100.101 |

### Wildcard CNAME

| Domain | Type | Target |
|---|---|---|
| *.homelab.local | CNAME | homelab.local |

Dengan konfigurasi ini:

```
auth.homelab.local
        |
        CNAME
        |
homelab.local
        |
        A
        |
192.168.100.101
```

Seluruh subdomain akan otomatis diarahkan ke Nginx Proxy Manager tanpa perlu membuat DNS record baru untuk setiap service.

Keuntungan:

- Menambahkan service baru tidak membutuhkan perubahan DNS
- Apabila IP Nginx Proxy Manager berubah, cukup update satu A record
- Struktur DNS lebih sederhana dan mudah dikelola

---

## Alternative: Individual Records (Not Recommended)

Apabila wildcard CNAME tidak digunakan, buat A record untuk setiap service:

| Domain | IP |
|---|---|
| pihole.homelab.local | 192.168.100.101 |
| npm.homelab.local | 192.168.100.101 |
| homepage.homelab.local | 192.168.100.101 |
| uptime.homelab.local | 192.168.100.101 |
| portainer.homelab.local | 192.168.100.101 |
| vault.homelab.local | 192.168.100.101 |
| adminer.homelab.local | 192.168.100.101 |
| auth.homelab.local | 192.168.100.101 |
| outline.homelab.local | 192.168.100.101 |
| stirling.homelab.local | 192.168.100.101 |
| postiz.homelab.local | 192.168.100.101 |

Metode ini tidak disarankan karena setiap penambahan service memerlukan perubahan DNS secara manual.

---

## Verify DNS Resolution

### From a client device

Windows:

```powershell
nslookup auth.homelab.local
```

Expected:

```text
Server:  192.168.100.101
Address: 192.168.100.101

Name: auth.homelab.local
Address: 192.168.100.101
```

---

### From Linux

```bash
dig outline.homelab.local
```

Expected:

```text
ANSWER SECTION:
outline.homelab.local. IN A 192.168.100.101
```

---

## Configure Client DNS

Agar device menggunakan Pihole:

### Router (Recommended)

Atur DHCP DNS server:

```
Primary DNS:
192.168.100.101
```

Keuntungan:

- Semua device otomatis mendapatkan DNS internal
- Tidak perlu konfigurasi manual setiap device

---

### Manual Device Configuration

Contoh:

```
DNS Server:
192.168.100.101
```

---

## DNS Cache Refresh

Setelah menambahkan record baru, refresh cache.

Windows:

```powershell
ipconfig /flushdns
```

Linux (systemd):

```bash
sudo resolvectl flush-caches
```

Browser:

- Restart browser
- Atau clear DNS cache browser

---

## Adding New Service

Contoh menambahkan service baru:

```
nextcloud.homelab.local
```

Karena menggunakan wildcard CNAME:

```
Tidak perlu membuat DNS record baru.
```

Cukup:

1. Deploy service baru
2. Buat Proxy Host di Nginx Proxy Manager
3. Assign SSL certificate `homelab-local`

DNS akan otomatis mengarahkan domain tersebut ke NPM.

---

## Troubleshooting

### Domain tidak dapat di-resolve

Periksa:

- Device menggunakan DNS Pihole
- Record terdapat pada Local DNS
- DNS cache sudah dibersihkan

Test:

```bash
nslookup homepage.homelab.local 192.168.100.101
```

---

### Domain resolve tetapi service tidak terbuka

Periksa:

- Nginx Proxy Manager berjalan
- Proxy Host sudah dibuat
- SSL certificate sudah di-assign

---

## Important Notes

- Jangan arahkan DNS record langsung ke IP masing-masing LXC.
- Seluruh service harus melewati Nginx Proxy Manager.
- LXC 101 adalah single entry point untuk seluruh HTTP/HTTPS service.
- Perubahan DNS tidak memerlukan restart Pihole.
- Gunakan wildcard CNAME (`*.homelab.local`) untuk mempermudah manajemen DNS.

---

*Last updated: 2026-06-18*