# Pi-hole Deployment

Panduan deployment Pi-hole v6 sebagai DNS server utama untuk seluruh jaringan homelab.

Pi-hole berjalan pada LXC 101 (`core-infra`) dan menjadi dependency utama bagi seluruh LXC lain.

---

## Prerequisites

Pastikan:

- LXC 101 sudah dibuat
- Docker sudah terinstall
- Directory `/opt/stacks` tersedia
- LXC menggunakan DNS publik (`1.1.1.1` atau `8.8.8.8`)

Referensi:

- `create-lxc.md`
- `docker-installation.md`
- `../../Infrastructure/network.md`

---

## 1. Create Stack Directory

```bash
mkdir -p /opt/stacks/pihole
cd /opt/stacks/pihole
```

---

## 2. Disable systemd-resolved

Ubuntu menggunakan `systemd-resolved` yang melakukan binding ke port `53`.

Karena Pi-hole juga menggunakan port `53`, service tersebut harus dinonaktifkan.

Stop dan disable:

```bash
systemctl stop systemd-resolved
systemctl disable systemd-resolved
```

---

## 3. Configure DNS Resolver

Hapus symbolic link bawaan:

```bash
rm /etc/resolv.conf
```

Buat resolver baru:

```bash
echo "nameserver 1.1.1.1" > /etc/resolv.conf
```

Verifikasi:

```bash
cat /etc/resolv.conf
```

Expected:

```
nameserver 1.1.1.1
```

> Jangan mengubah DNS LXC 101 menjadi `192.168.100.101` karena akan menyebabkan circular dependency apabila Pi-hole gagal berjalan.

---

## 4. Create docker-compose.yml

Buat file:

```bash
nano docker-compose.yml
```

Isi:

```yaml
services:
  pihole:
    image: pihole/pihole:latest
    container_name: pihole
    hostname: pihole
    restart: unless-stopped

    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "8080:80/tcp"

    environment:
      TZ: Asia/Jakarta
      FTLCONF_webserver_api_password: "your_password"
      PIHOLE_DNS_: "1.1.1.1;8.8.8.8"
      DNSMASQ_LISTENING: "all"

    volumes:
      - ./etc-pihole:/etc/pihole
      - ./etc-dnsmasq.d:/etc/dnsmasq.d

    cap_add:
      - NET_ADMIN

    healthcheck:
      test: ["CMD", "dig", "+short", "+norecurse", "+retry=0", "@127.0.0.1", "pi.hole"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

---

## 5. Deploy Container

Jalankan:

```bash
docker compose up -d
```

Verifikasi:

```bash
docker ps
```

Expected:

```
pihole    Up (healthy)
```

---

## 6. Configure Listening Mode

Pada beberapa kondisi, Pi-hole v6 tetap menggunakan:

```
listeningMode = "LOCAL"
```

sehingga DNS hanya menerima request dari localhost.

Ubah menjadi:

```
ALL
```

Jalankan:

```bash
docker exec pihole bash -c \
"sed -i 's/listeningMode = \"LOCAL\"/listeningMode = \"ALL\"/' /etc/pihole/pihole.toml"

docker restart pihole
```

Verifikasi:

```bash
docker exec pihole grep listeningMode /etc/pihole/pihole.toml
```

Expected:

```
listeningMode = "ALL"
```

---

## 7. Initial Access

Web UI dapat diakses melalui:

```
http://192.168.100.101:8080
```

Login menggunakan password yang dikonfigurasi pada:

```
FTLCONF_webserver_api_password
```

---

## 8. Configure Upstream DNS

Masuk ke:

```
Settings → DNS
```

Pastikan upstream DNS menggunakan:

- Cloudflare (`1.1.1.1`)
- Google (`8.8.8.8`)

---

## 9. Verify DNS Function

Test dari LXC lain:

```bash
ping google.com
```

Atau:

```bash
nslookup google.com 192.168.100.101
```

Expected:

```
Name: google.com
Address: <IP address>
```

---

## Post-Deployment Checklist

- [ ] Pi-hole container running
- [ ] Port 53 tidak digunakan systemd-resolved
- [ ] Web UI dapat diakses
- [ ] Password admin dikonfigurasi
- [ ] Upstream DNS aktif
- [ ] DNS query berhasil dari LXC lain

---

## Next Step

Setelah Pi-hole berjalan:

1. Deploy Nginx Proxy Manager
2. Buat DNS records internal
3. Konfigurasi SSL certificate

Runbooks:

- `nginx-proxy-manager-deployment.md`
- `../Configuration/pihole-dns-records.md`
- `../Configuration/ssl-self-signed.md`

---

*Last updated: 2026-06-18*