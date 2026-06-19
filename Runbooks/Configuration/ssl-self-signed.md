# SSL Self-Signed Wildcard Certificate

Panduan membuat wildcard SSL certificate untuk seluruh domain internal `*.homelab.local`.

Certificate ini digunakan oleh Nginx Proxy Manager untuk menyediakan HTTPS pada seluruh service homelab.

---

## Overview

Arsitektur SSL:

```text
Certificate:
    *.homelab.local
           |
           |
    +------+-------------------------------+
    |      |       |        |               |
 pihole  npm   auth    outline       dan seterusnya
```

Keuntungan menggunakan wildcard certificate:

- Satu certificate untuk seluruh service
- Tidak perlu membuat certificate per domain
- Mudah melakukan penambahan service baru
- Mendukung HTTPS di jaringan internal tanpa internet

---

## Certificate Location

Certificate dibuat di workstation administrator.

Contoh:

```text
~/homelab-cert/
├── homelab-local.key
├── homelab-local.crt
└── homelab-local.cnf
```

---

## Create OpenSSL Configuration

Buat folder kerja:

```bash
mkdir -p ~/homelab-cert
cd ~/homelab-cert
```

Buat file konfigurasi:

```bash
nano homelab-local.cnf
```

Isi:

```ini
[req]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[dn]
C = ID
ST = West Java
L = Banjar
O = Homelab
OU = Infrastructure
CN = *.homelab.local

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.homelab.local
DNS.2 = homelab.local
```

---

## Generate Private Key

Jalankan:

```bash
openssl genrsa -out homelab-local.key 4096
```

Hasil:

```
homelab-local.key
```

> Jangan upload private key ke repository Git.

---

## Generate Certificate Signing Request (CSR)

```bash
openssl req \
-new \
-key homelab-local.key \
-out homelab-local.csr \
-config homelab-local.cnf
```

---

## Generate Self-Signed Certificate

Buat certificate dengan masa berlaku 10 tahun:

```bash
openssl x509 \
-req \
-in homelab-local.csr \
-signkey homelab-local.key \
-out homelab-local.crt \
-days 3650 \
-extensions req_ext \
-extfile homelab-local.cnf
```

Hasil akhir:

```text
homelab-local.key
homelab-local.crt
```

---

## Verify Certificate

Cek informasi certificate:

```bash
openssl x509 -in homelab-local.crt -text -noout
```

Pastikan terdapat:

```text
Subject:
    CN = *.homelab.local

X509v3 Subject Alternative Name:
    DNS:*.homelab.local
    DNS:homelab.local
```

---

## Import Certificate into Nginx Proxy Manager

Login ke:

```
https://npm.homelab.local
```

Masuk ke:

```
SSL Certificates
    ↓
Add SSL Certificate
    ↓
Custom
```

Isi:

| Field | Value |
|---|---|
| Name | `homelab-local` |
| Certificate | `homelab-local.crt` |
| Certificate Key | `homelab-local.key` |

Save.

---

## Configure Proxy Host

Saat membuat proxy host:

```
SSL tab
    ↓
Certificate: homelab-local
    ↓
Enable:
✓ Force SSL
✓ HTTP/2 Support
```

---

## Install Certificate Authority (Optional)

Karena certificate bersifat self-signed, browser akan memberikan warning:

```
Your connection is not private
```

Untuk menghilangkan warning:

- Import `homelab-local.crt` ke Trusted Root Certificate Store pada device yang digunakan.

Contoh:

- Windows
- macOS
- Android
- iOS

Setelah dipercaya, seluruh domain:

```
*.homelab.local
```

akan tampil tanpa warning.

---

## Renewal Procedure

Certificate berlaku selama:

```
3650 hari (±10 tahun)
```

Sebelum expired:

1. Generate certificate baru
2. Upload ulang ke NPM
3. Ganti certificate pada semua proxy host

---

## Backup Strategy

Backup file berikut:

```
homelab-local.key
homelab-local.crt
homelab-local.cnf
```

Simpan pada lokasi aman seperti:

- Encrypted external storage
- Password manager attachment
- Backup repository yang private dan terenkripsi

---

## Security Notes

- Private key adalah aset paling sensitif dalam SSL.
- Jangan pernah commit `homelab-local.key` ke GitHub.
- Kehilangan private key akan mengharuskan pembuatan certificate baru.
- Siapa pun yang memiliki private key dapat melakukan impersonasi domain `*.homelab.local`.

---

## Troubleshooting

### Browser masih menunjukkan warning

Periksa:

- Certificate sudah di-import ke trusted root
- Browser sudah direstart
- DNS mengarah ke NPM dengan certificate yang benar

---

### NPM menampilkan "Invalid Certificate"

Periksa:

```bash
openssl x509 -in homelab-local.crt -text -noout
```

Pastikan:

- Certificate belum expired
- Private key sesuai dengan certificate

---

*Last updated: 2026-06-18*