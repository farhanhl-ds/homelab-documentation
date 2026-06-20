# Troubleshooting

Kumpulan masalah yang pernah ditemui beserta langkah penyelesaiannya.


---

## Proxmox

### Proxmox gagal boot setelah instalasi

Apabila Proxmox tidak masuk ke sistem setelah instalasi, lakukan pemeriksaan berikut.

| **Masalah** | **Penyebab** | **Solusi** |
|---------|----------|--------|
| Sistem masuk ke PXE / network boot | Prioritas SSD berada di bawah PXE pada boot order | Masuk ke BIOS dan pindahkan SSD ke prioritas boot pertama |
| Muncul error `Secure Boot violation` | Secure Boot masih aktif | Masuk ke BIOS → Security → Disable Secure Boot |
| VM tidak dapat dibuat | Intel VT-x atau VT-d belum aktif | Masuk ke BIOS → CPU → Enable Intel Virtualization |


---

## LXC / Docker

### Pihole gagal start karena port 53 sudah digunakan

Pihole membutuhkan port `53` untuk layanan DNS. Masalah ini biasanya terjadi karena `systemd-resolved` masih berjalan dan sudah menggunakan port tersebut.

Matikan `systemd-resolved`, kemudian atur ulang DNS resolver:

```bash
systemctl stop systemd-resolved
systemctl disable systemd-resolved
rm /etc/resolv.conf
echo "nameserver 1.1.1.1" > /etc/resolv.conf
```


---

### Container tidak dapat mengakses internet

Apabila `docker pull` gagal atau container tidak dapat melakukan DNS resolve, periksa konfigurasi DNS terlebih dahulu.

Jalankan pengecekan berikut:

```bash
cat /etc/resolv.conf
ping 1.1.1.1
nslookup google.com
```

Pastikan file `/etc/resolv.conf` memiliki `nameserver` yang valid, misalnya:

```javascript
nameserver 1.1.1.1
```


---

### Docker Compose service gagal berjalan

Saat sebuah service gagal start, langkah pertama adalah membaca log container untuk mengetahui penyebabnya.

Periksa log dan status container:

```bash
docker compose logs <service-name>
docker ps -a
```

Setelah masalah diperbaiki, lakukan recreate container:

```javascript
docker compose up -d --force-recreate
```


---

## DNS & Network (`.homelab.local`)

Arsitektur DNS internal Homelab menggunakan alur berikut:

```
Browser → Pihole DNS (resolve domain) → NPM (routing ke port) → Service
```

Apabila domain `.homelab.local` tidak dapat diakses, lakukan troubleshooting mengikuti urutan alur di atas.


---

### Pastikan Pihole dapat dijangkau

Cek konektivitas ke server Pihole:

```javascript
ping 192.168.100.101
```

Apabila ping gagal, periksa koneksi jaringan, IP address, atau status LXC Pihole.


---

### Client belum menggunakan Pihole sebagai DNS

Domain `.homelab.local` hanya dapat di-resolve apabila client menggunakan Pihole sebagai DNS server.

Periksa DNS yang sedang digunakan:

```javascript
Get-DnsClientServerAddress
```

Pastikan DNS IPv4 mengarah ke Pihole:

```javascript
ServerAddresses:
  192.168.100.101
  1.1.1.1
```

Apabila DNS belum sesuai, lihat daftar adapter dan cari nama atau Interface Index yang digunakan:

```javascript
Get-NetAdapter
```

Atur DNS ke Pihole:

```javascript
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("192.168.100.101","1.1.1.1") 
ipconfig /flushdns
```

Apabila menggunakan Interface Index:

```javascript
Set-DnsClientServerAddress -InterfaceIndex 19 -ServerAddresses ("192.168.100.101","1.1.1.1") 
ipconfig /flushdns
```

Verifikasi DNS yang sedang digunakan:

```javascript
nslookup vault.homelab.local 192.168.100.101
```

Pastikan DNS server yang muncul adalah:

```javascript
Server: 192.168.100.101
```


---

### DNS request tetap menggunakan IPv6 dari router

Windows secara default lebih memprioritaskan IPv6 dibanding IPv4. Akibatnya, DNS IPv6 dari router dapat menggantikan konfigurasi DNS IPv4 yang sudah diarahkan ke Pihole.

Matikan IPv6 pada adapter Wi-Fi:

```javascript
Disable-NetAdapterBinding -Name "Wi-Fi" -ComponentID ms_tcpip6 
ipconfig /flushdns
```

Verifikasi status IPv6:

```javascript
Get-NetAdapterBinding -Name "Wi-Fi" -ComponentID ms_tcpip6
```

Output yang diharapkan:

```javascript
Enabled : False
```

Untuk mengaktifkan kembali IPv6:

```javascript
Enable-NetAdapterBinding -Name "Wi-Fi" -ComponentID ms_tcpip6
```

> ⚠️ Jika IPv6 diaktifkan kembali, Windows dapat kembali menggunakan DNS dari router sehingga domain `.homelab.local` tidak dapat di-resolve.


---

### Pihole hanya menerima request dari Docker internal network

Apabila `nslookup` sudah mengarah ke `192.168.100.101` tetapi tetap menghasilkan timeout atau `Unspecified error`, kemungkinan Pihole masih menggunakan konfigurasi default `listeningMode = "LOCAL"`.

Ubah `listeningMode` Pihole menjadi `ALL`:

```javascript
docker exec pihole bash -c "sed -i 's/listeningMode = \"LOCAL\"/listeningMode = \"ALL\"/' /etc/pihole/pihole.toml"
docker restart pihole
```

Verifikasi kembali:

```javascript
nslookup vault.homelab.local 192.168.100.101
```

Request harus berhasil dan mengembalikan IP service yang sesuai.

> Catatan: DNS menggunakan UDP sebagai protokol utama. TCP port 53 dapat terlihat terbuka sementara UDP masih mengalami masalah.


---

### Domain resolve tetapi website tidak dapat dibuka

Apabila `nslookup` berhasil tetapi website masih bermasalah, lanjutkan pengecekan berikut.

#### Error 502 atau 503

Nginx Proxy Manager berhasil menerima request, tetapi service tujuan tidak tersedia.

Periksa status container atau service pada node tujuan.


---

### Pihole menampilkan error 403 melalui Nginx Proxy Manager

Pihole Admin UI berjalan pada path `/admin`. Apabila Nginx Proxy Manager melakukan forwarding ke `/`, Pihole akan menampilkan error 403.

Buka NPM, edit proxy host `pihole.homelab.local`, lalu tambahkan Custom Location berikut:

| **Field** | **Value** |
|-------|-------|
| Location | `/`   |
| Forward Hostname / IP | `192.168.100.101` |
| Forward Port | `8080` |

Tambahkan konfigurasi Nginx:

```nginx
rewrite ^/$ /admin redirect;
```


---

### Homepage gagal karena Host Validation

Homepage melakukan validasi host sebelum membaca file `settings.yaml`. Oleh karena itu, pengaturan `allowed_hosts` di dalam file konfigurasi tidak akan berpengaruh.

Tambahkan environment variable pada `docker-compose.yml`:

```yaml
environment:
  - HOMEPAGE_ALLOWED_HOSTS=homepage.homelab.local
```

Lakukan recreate container:

```bash
docker compose up -d --force-recreate
```


---

## Nginx Proxy Manager

### Tidak dapat membuat SSL certificate untuk domain `.homelab.local`

Fitur **Request a new Certificate** di Nginx Proxy Manager menggunakan Let's Encrypt dan hanya dapat digunakan untuk domain publik. Domain internal seperti `.homelab.local` tidak dapat diverifikasi oleh Let's Encrypt.

Gunakan self-signed certificate sebagai alternatif.

Generate certificate:

```javascript
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \ 
  -keyout /opt/stacks/npm/homelab.key \ 
  -out /opt/stacks/npm/homelab.crt \ 
  -subj "/CN=*.homelab.local"
```

Setelah generate selesai:


1. Buka Nginx Proxy Manager.
2. Masuk ke **SSL Certificates**.
3. Pilih **Add SSL Certificate**.
4. Gunakan opsi **Custom Certificate**.
5. Upload file `homelab.crt` dan `homelab.key`.

Lihat panduan lengkap pada [SSL Self-Signed](/doc/5f8d1d87-2676-4617-841b-6bac818e7d97) .


---

## Authentik

### Authentik restart terus karena PermissionError pada folder media

Saat deployment pertama, Authentik dapat gagal membuat file pada volume mount karena permission owner tidak sesuai.

Buat directory yang diperlukan dan ubah ownership menjadi UID `1000`:

```bash
mkdir -p /opt/stacks/authentik/media \
  /opt/stacks/authentik/custom-templates \
  /opt/stacks/authentik/certs
```

```javascript
chown -R 1000:1000 /opt/stacks/authentik/media \
  /opt/stacks/authentik/custom-templates \
  /opt/stacks/authentik/certs
```

```javascript
docker compose restart
```


---

### Authentik menampilkan HTML mentah saat diakses melalui domain

Apabila halaman Authentik menampilkan source HTML secara langsung, kemungkinan Authentik tidak mempercayai `X-Forwarded` header yang dikirim oleh Nginx Proxy Manager.

Tambahkan konfigurasi berikut pada Custom Nginx Config:

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Host $host;
```

Tambahkan juga trusted proxy pada file `.env`:

```env
AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS=192.168.100.0/24
```

Kedua konfigurasi harus diterapkan bersamaan.


---

### Authentik gagal terhubung ke Redis setelah password berubah

Update password Redis pada file `.env`:

```env
AUTHENTIK_REDIS__PASSWORD=new_redis_password
```

Kemudian recreate container:

```bash
docker compose up -d --force-recreate
```


---

### Login Loop Setelah Menambahkan AUTHENTIK_HOST

Variable `AUTHENTIK_HOST` dan `AUTHENTIK_HOST_BROWSER` dapat menyebabkan login loop dan membuat Authentik tidak dapat diakses.

Biarkan kedua variable tersebut tidak terdefinisi kecuali memang diperlukan oleh dokumentasi resmi.


---

## Outline

### Password database gagal dibaca karena karakter khusus

Connection string PostgreSQL menggunakan format URL. Karakter seperti `/`, `+`, dan `=` pada password dapat menyebabkan parsing gagal.

Gunakan password dengan format hexadecimal:

```javascript
openssl rand -hex 16
```

Setelah mengganti password:

* Update password PostgreSQL.
* Update file `.env` Outline.
* Update `init.sql` apabila melakukan fresh deployment.


---

### Outline tidak dapat resolve domain internal Authentik

Container Outline menggunakan Docker DNS bawaan sehingga tidak mengetahui domain internal `.homelab.local`.

Tambahkan DNS override pada `docker-compose.yml`:

```yaml
    dns:
      - 192.168.100.101
```


---

### Outline gagal melakukan OIDC callback karena self-signed certificate

Outline tidak mempercayai self-signed certificate milik Authentik.

Tambahkan di environment `docker-compose.yml`:

```yaml
NODE_TLS_REJECT_UNAUTHORIZED: "0"
```


---

### Outline menampilkan halaman Not Found saat redirect ke Authentik

Penyebabnya adalah endpoint `OIDC_AUTH_URI` yang salah.

Jangan gunakan:

```javascript
/application/o/outline/authorize/
```

Gunakan endpoint yang didapat dari discovery endpoint:

```
https://auth.homelab.local/application/o/outline/
```

Periksa nilai `authorization_endpoint`, kemudian update:

```env
OIDC_AUTH_URI=https://auth.homelab.local/application/o/authorize/
```


---

### Outline gagal membuat secure cookie

Log `Error: Cannot send secure cookie over unencrypted connection`

Pastikan konfigurasi berikut sudah benar:


1. `URL` menggunakan HTTPS dan domain, bukan IP.
2. `FORCE_HTTPS=true` sudah diaktifkan.
3. NPM proxy host sudah dikonfigurasi dengan SSL


---

### Outline restart terus setelah deployment pertama

Periksa log terlebih dahulu:

```bash
docker compose logs outline --tail=50
```

Masalah yang umum ditemukan:

| **Error** | **Penyebab** | **Solusi** |
|-------|----------|--------|
| `The server does not support SSL connections` | PostgreSQL tidak pakai SSL, Outline expect SSL | Tambah `PGSSLMODE: "disable"` di environment |
| `Gracefully quitting` loop | Efek dari error PostgreSQL sebelumnya | Perbaiki konfigurasi `PGSSLMODE` terlebih dahulu |


---

## Catatan Insiden

Riwayat masalah penting yang pernah terjadi pada homelab.

| **Tanggal** | **Gejala** | **Root Cause** | **Penyelesaian** |
|---------|--------|------------|--------------|
| 2025-06 | Proxmox gagal boot | Boot order salah dan Secure Boot aktif | Ubah boot priority dan matikan Secure Boot |
| 2026-06-14 | Domain `.homelab.local` tidak dapat di-resolve | Windows prefer IPv6 + Pihole listeningMode LOCAL | Disable IPv6 dan ubah `listeningMode` menjadi `ALL` |
| 2026-06-15 | Login Outline melalui OIDC gagal | DNS internal, self-signed certificate, dan OIDC URI tidak sesuai | Tambahkan DNS override, bypass TLS validation, dan perbaiki endpoint OIDC |


---

*Last updated: 2026-06-17*