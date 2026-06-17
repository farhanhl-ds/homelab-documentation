Panduan generate dan setup wildcard self-signed certificate `*.homelab.local` untuk semua service internal via Nginx Proxy Manager.

> Domain `.homelab.local` adalah internal domain yang tidak dapat diverifikasi oleh CA publik seperti Let's Encrypt. Self-signed certificate sudah mencukupi untuk kebutuhan homelab personal: gratis, tidak memerlukan renewal rutin, dan mudah di-setup.

---

## Step 1 — Generate Certificate

Jalankan dari LXC core-infra:

```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /opt/stacks/npm/homelab.key \
  -out /opt/stacks/npm/homelab.crt \
  -subj "/CN=*.homelab.local"
```

Output dua file:
- `homelab.crt` — certificate (public)
- `homelab.key` — private key (jangan dibagikan)

> `-days 3650` = valid 10 tahun, tidak memerlukan renewal rutin. Output berupa karakter `+` dan `.` saat command berjalan adalah normal — itu proses generate key pair.

---

## Step 2 — Download Certificate ke Laptop

Jalankan dari PowerShell Windows:

```powershell
scp root@192.168.100.101:/opt/stacks/npm/homelab.crt C:\Users\Farhan\Downloads\
scp root@192.168.100.101:/opt/stacks/npm/homelab.key C:\Users\Farhan\Downloads\
```

> Simpan kedua file ini di Vaultwarden sebagai backup agar tidak perlu generate ulang apabila LXC di-recreate.

---

## Step 3 — Upload Certificate ke NPM

1. Buka NPM: `http://192.168.100.101:81`
2. **Certificates** → **Add Certificate** → **Custom Certificate**
3. Isi:
   - **Name:** `homelab-local`
   - **Certificate Key:** upload `homelab.key`
   - **Certificate:** upload `homelab.crt`
   - **Intermediate Certificate:** kosongkan
4. **Save**

---

## Step 4 — Assign Certificate ke Proxy Host

Lakukan untuk setiap service. Contoh untuk Vaultwarden:

1. **Hosts** → **Proxy Hosts** → cari service → klik titik tiga → **Edit**
2. Tab **Details**:

| Field | Value |
|---|---|
| Domain | vault.homelab.local |
| Scheme | http |
| Forward Hostname | 192.168.100.102 |
| Forward Port | 8080 |
| Websockets Support | ✅ |

3. Tab **SSL**:

| Field | Value |
|---|---|
| SSL Certificate | homelab-local |
| Force SSL | ✅ |
| HTTP/2 Support | Opsional |
| HSTS | ❌ |

4. **Save**

Untuk service lain, cukup ulangi langkah ini dan pilih cert `homelab-local` — tidak perlu generate cert baru karena wildcard `*.homelab.local` berlaku untuk semua subdomain.

---

## Step 5 — Test Akses

Buka browser dan akses salah satu service via HTTPS, contoh: `https://vault.homelab.local`.

> Apabila browser menampilkan peringatan "Not secure", ini adalah perilaku normal untuk self-signed certificate. Koneksi tetap terenkripsi. Untuk menghilangkan peringatan ini, lanjutkan ke Step 6.

---

## Step 6 — (Opsional) Install Certificate ke Windows Certificate Store

Dengan menginstall certificate ke Windows Certificate Store, Chrome dan Edge akan mempercayai `homelab.crt` dan tidak lagi menampilkan peringatan "Not secure" untuk semua domain `*.homelab.local`.

Jalankan di PowerShell sebagai Administrator:

```powershell
certutil -addstore "Root" C:\Users\Farhan\Downloads\homelab.crt
```

Restart browser setelah install.

**Verifikasi:**
```powershell
certutil -store "Root" | findstr "homelab"
```

**Hapus certificate:**
```powershell
certutil -delstore "Root" "*.homelab.local"
```

> **Firefox** memiliki Certificate Store tersendiri — perlu import manual via Settings → Privacy & Security → Certificates → Import.

---

## Apabila LXC atau NPM Di-recreate

Certificate di NPM akan hilang apabila LXC core-infra di-recreate. Langkah pemulihan:

1. Gunakan file `homelab.crt` dan `homelab.key` dari backup laptop atau Vaultwarden
2. Re-upload ke NPM (Step 3)
3. Re-assign ke seluruh proxy host (Step 4)

---

## Summary

| Step | Action | Lokasi |
|---|---|---|
| Generate cert | `openssl req ...` | LXC core-infra |
| Download cert | `scp ...` | PowerShell Windows |
| Upload ke NPM | Custom Certificate | NPM UI |
| Assign ke service | Edit proxy host → SSL tab | NPM UI |
| Trust di browser | `certutil -addstore` (opsional) | PowerShell as Admin |

---

## Referensi: Migrasi ke Let's Encrypt

Apabila di kemudian hari terdapat domain publik, certificate dapat dimigrasikan ke Let's Encrypt sehingga browser mempercayainya secara otomatis tanpa instalasi manual.

### Perbandingan

| | Self-Signed (sekarang) | Let's Encrypt |
|---|---|---|
| **Biaya** | Gratis | Gratis |
| **Browser trust** | ❌ Perlu install manual | ✅ Otomatis |
| **Domain** | Internal (`.homelab.local`) | Harus domain publik |
| **Expiry** | 10 tahun | 90 hari, auto-renew |
| **Setup** | Manual generate + upload | NPM auto-request via ACME |

### Metode Validasi

**A. HTTP Challenge** — paling sederhana, memerlukan port 80 terbuka:
1. NPM → SSL Certificates → Add Certificate → **Let's Encrypt**
2. Isi domain → NPM akan auto-request dan auto-renew setiap 90 hari

**B. DNS Challenge** — tidak memerlukan port terbuka, lebih cocok untuk homelab:
1. NPM → SSL Certificates → Add Certificate → **Let's Encrypt**
2. Enable **Use DNS Challenge** → pilih DNS provider (Cloudflare, dll) → isi API token
3. NPM memverifikasi kepemilikan domain via DNS record

> Rekomendasi: gunakan DNS Challenge via Cloudflare agar tidak perlu mengekspos port ke internet.

---

*Last updated: 2026-06-16*
