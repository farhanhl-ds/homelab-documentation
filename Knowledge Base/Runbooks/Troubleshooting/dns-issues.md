# DNS Issues

Troubleshooting masalah DNS internal Homelab.

Arsitektur DNS menggunakan alur berikut:

```text
Client
  ↓
Pi-hole DNS
  ↓
Resolve *.homelab.local
  ↓
Nginx Proxy Manager
  ↓
Target Service
```

Apabila domain `.homelab.local` tidak dapat diakses, lakukan troubleshooting sesuai urutan berikut.

---

# Domain `.homelab.local` tidak dapat di-resolve

## Symptoms

* Browser menampilkan `DNS_PROBE_FINISHED_NXDOMAIN`.
* `nslookup` menghasilkan timeout.
* Domain seperti `vault.homelab.local` tidak dapat ditemukan.

---

# Troubleshooting Flow

```text
Domain gagal resolve
          |
          v
Apakah Pi-hole dapat dijangkau?
          |
    +-----+------+
    |            |
   Tidak         Ya
    |            |
Network       Apakah client
 Issues       menggunakan Pi-hole?
                    |
              +-----+-----+
              |           |
             Tidak        Ya
              |           |
       Perbaiki DNS    Apakah Pi-hole
       Client          menerima request?
                            |
                      +-----+-----+
                      |           |
                     Tidak        Ya
                      |           |
               Fix listening     Periksa DNS
               Mode              Records
```

---

# Diagnosis

## 1. Periksa konektivitas ke Pi-hole

Dari client:

```powershell
ping 192.168.100.101
```

Apabila gagal:

* Periksa koneksi jaringan.
* Pastikan LXC 101 sedang berjalan.
* Lanjutkan troubleshooting pada `network-issues.md`.

---

## 2. Periksa DNS yang digunakan client

Pada Windows:

```powershell
Get-DnsClientServerAddress
```

Pastikan DNS IPv4 mengarah ke Pi-hole:

```text
ServerAddresses:
  192.168.100.101
  1.1.1.1
```

Jika belum sesuai, lihat adapter yang digunakan:

```powershell
Get-NetAdapter
```

Konfigurasi DNS menggunakan nama adapter:

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" `
  -ServerAddresses ("192.168.100.101","1.1.1.1")

ipconfig /flushdns
```

Atau menggunakan Interface Index:

```powershell
Set-DnsClientServerAddress -InterfaceIndex 19 `
  -ServerAddresses ("192.168.100.101","1.1.1.1")

ipconfig /flushdns
```

---

## 3. Windows tetap menggunakan DNS IPv6 dari router

### Symptoms

* DNS IPv4 sudah menunjuk ke Pi-hole.
* `nslookup` tetap gagal.
* Request masih melewati DNS IPv6 dari router.

### Root Cause

Windows memiliki prioritas lebih tinggi terhadap DNS IPv6 dibanding IPv4.

### Resolution

Nonaktifkan IPv6 pada adapter Wi-Fi:

```powershell
Disable-NetAdapterBinding `
  -Name "Wi-Fi" `
  -ComponentID ms_tcpip6

ipconfig /flushdns
```

Verifikasi:

```powershell
Get-NetAdapterBinding `
  -Name "Wi-Fi" `
  -ComponentID ms_tcpip6
```

Output yang diharapkan:

```text
Enabled : False
```

Untuk mengaktifkan kembali IPv6:

```powershell
Enable-NetAdapterBinding `
  -Name "Wi-Fi" `
  -ComponentID ms_tcpip6
```

> ⚠️ Apabila IPv6 diaktifkan kembali, Windows dapat kembali menggunakan DNS dari router sehingga domain internal mungkin gagal di-resolve.

---

## 4. Pi-hole tidak menerima request dari LAN

### Symptoms

* `nslookup` menggunakan server `192.168.100.101`.
* Request menghasilkan timeout atau `Unspecified error`.

Contoh:

```text
Server:  192.168.100.101

DNS request timed out.
timeout was 2 seconds.
```

### Root Cause

Pi-hole masih menggunakan:

```text
listeningMode = "LOCAL"
```

Mode ini hanya menerima request dari internal Docker network.

### Resolution

Ubah konfigurasi menjadi:

```text
listeningMode = "ALL"
```

Jalankan:

```bash
docker exec pihole bash -c \
"sed -i 's/listeningMode = \"LOCAL\"/listeningMode = \"ALL\"/' /etc/pihole/pihole.toml"

docker restart pihole
```

Verifikasi kembali:

```powershell
nslookup vault.homelab.local 192.168.100.101
```

DNS harus mengembalikan IP yang sesuai.

> Catatan:
> DNS menggunakan UDP sebagai protokol utama. Port TCP 53 dapat terlihat terbuka meskipun request DNS UDP masih gagal.

---

## 5. DNS record belum dibuat atau salah

Periksa menggunakan:

```powershell
nslookup vault.homelab.local 192.168.100.101
```

Apabila muncul:

```text
Non-existent domain
```

Periksa konfigurasi:

* DNS Record
* CNAME Record
* Local DNS pada Pi-hole

Lihat dokumentasi:

```text
Runbooks/Configurations/pihole-dns-records.md
```

---

# Verification Checklist

Setelah perbaikan dilakukan, pastikan:

| Check                                         | Expected Result             |
| --------------------------------------------- | --------------------------- |
| `ping 192.168.100.101`                        | Berhasil                    |
| `Get-DnsClientServerAddress`                  | Menggunakan Pi-hole         |
| `nslookup vault.homelab.local`                | Mengembalikan IP yang benar |
| Pi-hole `listeningMode`                       | `ALL`                       |
| Browser membuka `https://vault.homelab.local` | Berhasil                    |

---

# Prevention

* Gunakan Pi-hole sebagai DNS utama seluruh client.
* Dokumentasikan DNS records sebelum menambah service baru.
* Hindari mengaktifkan kembali IPv6 tanpa konfigurasi DNS IPv6 yang benar.
* Simpan konfigurasi DNS Windows sebagai quick recovery procedure.

---

# Related Documents

* `Infrastructure/network.md`
* `Services/pihole.md`
* `Runbooks/Configurations/pihole-dns-records.md`
* `Runbooks/Operations/power-recovery.md`

---

# Incident History

## 2026-06-14 — The Great DNS War

### Symptoms

Seluruh domain `.homelab.local` tidak dapat diakses meskipun semua container berjalan normal.

### Root Causes

1. Windows menggunakan DNS IPv6 dari router.
2. Pi-hole hanya menerima request dari Docker network (`listeningMode = LOCAL`).

### Resolution

* Nonaktifkan IPv6 pada adapter Windows.
* Ubah Pi-hole `listeningMode` menjadi `ALL`.
* Flush DNS cache dan lakukan verifikasi menggunakan `nslookup`.

### Lessons Learned

Jangan langsung menyalahkan Docker, NPM, atau aplikasi.

Lakukan troubleshooting sesuai urutan:

```
Network → DNS → Reverse Proxy → Application
```

---

*Last updated: 2026-06-20*
