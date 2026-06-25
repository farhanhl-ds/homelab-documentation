# Stirling PDF Deployment

Panduan deployment Stirling PDF sebagai aplikasi self-hosted untuk manipulasi dokumen PDF.

Stirling PDF berjalan pada LXC 105 (`productivity`).

---

## Prerequisites

Pastikan:

- LXC 105 sudah dibuat
- Docker sudah terinstall
- DNS record `stirling.homelab.local` sudah tersedia di Pihole
- SSL certificate `homelab-local` sudah tersedia di Nginx Proxy Manager (NPM)

Referensi:

- `create-lxc-guide.md`
- `docker-installation.md`
- `nginx-proxy-manager-deployment.md`

---

## 1. Create Stack Directory

Buat directory untuk stack:

```bash
mkdir -p /opt/stacks/stirling-pdf
cd /opt/stacks/stirling-pdf

mkdir trainingData configs
```

---

## 2. Create `docker-compose.yml`

Buat file:

```bash
nano docker-compose.yml
```

Isi:

```yaml
services:
  stirling-pdf:
    image: frooodle/s-pdf:latest
    container_name: stirling-pdf
    restart: unless-stopped

    ports:
      - "8080:8080"

    volumes:
      - ./trainingData:/usr/share/tessdata
      - ./configs:/configs
```

---

## 3. Deploy Container

Jalankan:

```bash
docker compose up -d
```

Verifikasi:

```bash
docker ps
```

Pastikan container `stirling-pdf` berstatus:

```text
Up
```

---

## 4. Configure Nginx Proxy Manager

Buat Proxy Host:

| Field | Value |
|---|---|
| Domain | stirling.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.105 |
| Forward Port | 8080 |
| Websocket Support | Enable |
| SSL Certificate | homelab-local |
| Force SSL | Enable |

---

## 5. Verify Access

Buka:

```
https://stirling.homelab.local
```

Pastikan:

- Halaman Stirling PDF muncul
- HTTPS aktif menggunakan certificate `homelab-local`
- Upload dan convert PDF berhasil

---

## Optional Configuration

### OCR Language Pack

Secara default container sudah menyediakan bahasa tertentu.

Apabila membutuhkan OCR tambahan, download file `.traineddata` dan simpan pada:

```
/opt/stacks/stirling-pdf/trainingData
```

Restart container:

```bash
docker restart stirling-pdf
```

---

### Custom Application Configuration

File konfigurasi dapat disimpan pada:

```
/opt/stacks/stirling-pdf/configs
```

Contoh penggunaan:

- Mengubah setting aplikasi
- Mengatur security policy
- Mengubah konfigurasi OCR

---

## Backup Strategy

Backup directory berikut:

```
/opt/stacks/stirling-pdf
```

Karena seluruh konfigurasi dan data tambahan berada pada directory tersebut.

---

## Troubleshooting

### Container gagal start

Periksa log:

```bash
docker logs stirling-pdf --tail 50
```

---

### Tidak bisa diakses melalui domain

Periksa:

- DNS record `stirling.homelab.local`
- NPM Proxy Host
- SSL certificate assignment

Test koneksi langsung:

```
http://192.168.100.105:8080
```

Jika URL IP berjalan tetapi domain tidak, masalah berada pada DNS atau NPM.

---

## Post-Deployment Checklist

- [ ] Container Stirling PDF running
- [ ] Stirling PDF accessible via HTTPS
- [ ] NPM Proxy Host dikonfigurasi
- [ ] Test upload PDF berhasil
- [ ] Backup strategy dibuat

---

## Next Step

Setelah Stirling PDF selesai, lanjutkan deployment aplikasi terakhir pada LXC 105:

`postiz-deployment.md`

---

*Last updated: 2026-06-18*