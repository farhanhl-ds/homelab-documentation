# Authentik OIDC Configuration

Panduan konfigurasi OpenID Connect (OIDC) menggunakan Authentik sebagai Identity Provider (IdP) untuk seluruh aplikasi homelab.

---

## Overview

Authentik bertindak sebagai pusat autentikasi.

Semua aplikasi yang mendukung OIDC akan melakukan login melalui Authentik.

Arsitektur:

```text
User
 |
 v
Application
 |
 | Redirect login
 v
Authentik
 |
 | Verify credential
 v
OIDC Token
 |
 v
Application
```

Keuntungan:

- Single Sign-On (SSO)
- Satu akun untuk seluruh aplikasi
- Centralized access management
- Mendukung MFA / 2FA
- Audit login activity

---

## Authentik Information

| Item | Value |
|---|---|
| URL | https://auth.homelab.local |
| Admin UI | https://auth.homelab.local/if/admin/ |
| OIDC Base URL | https://auth.homelab.local/application/o/ |

---

## General OIDC Flow

Setiap aplikasi membutuhkan:

| Parameter | Source |
|---|---|
| Client ID | Authentik Provider |
| Client Secret | Authentik Provider |
| Authorization Endpoint | Authentik |
| Token Endpoint | Authentik |
| User Info Endpoint | Authentik |
| Redirect URI | Application |

---

## Standard Authentik Endpoints

Gunakan endpoint berikut:

| Endpoint | URL |
|---|---|
| Authorization | https://auth.homelab.local/application/o/authorize/ |
| Token | https://auth.homelab.local/application/o/token/ |
| UserInfo | https://auth.homelab.local/application/o/userinfo/ |

---

# Creating OIDC Provider

Login ke Authentik:

```
Applications
 ↓
Providers
 ↓
Create
 ↓
OAuth2/OpenID Provider
```

Konfigurasi standar:

| Field | Value |
|---|---|
| Authorization Flow | default-provider-authorization-explicit-consent |
| Client Type | Confidential |
| Signing Key | Default |

Setelah dibuat:

1. Catat Client ID
2. Catat Client Secret
3. Simpan ke Vaultwarden

---

# Creating Application

Setelah provider dibuat:

```
Applications
 ↓
Applications
 ↓
Create
```

Isi:

| Field | Value |
|---|---|
| Name | Nama aplikasi |
| Slug | Nama aplikasi lowercase |
| Provider | Provider yang dibuat sebelumnya |

---

# Current Integrations

## Outline

### Provider

| Field | Value |
|---|---|
| Name | outline-provider |
| Client Type | Confidential |
| Authorization Flow | default-provider-authorization-explicit-consent |

### Redirect URI

```
https://outline.homelab.local/auth/oidc.callback
```

### Outline Environment Variables

```env
OIDC_CLIENT_ID=your_client_id
OIDC_CLIENT_SECRET=your_client_secret

OIDC_AUTH_URI=https://auth.homelab.local/application/o/authorize/
OIDC_TOKEN_URI=https://auth.homelab.local/application/o/token/
OIDC_USERINFO_URI=https://auth.homelab.local/application/o/userinfo/

OIDC_SCOPES=openid profile email
OIDC_DISPLAY_NAME=Homelab SSO
```

---

## Postiz

Status:

```
Pending
```

Akan dikonfigurasi saat Postiz membutuhkan SSO.

---

## Future Applications

Untuk aplikasi baru:

1. Buat OIDC Provider baru di Authentik
2. Tentukan Redirect URI aplikasi
3. Simpan Client ID dan Secret di Vaultwarden
4. Masukkan credential ke environment variable aplikasi
5. Test login flow

---

# Security Best Practices

## Client Secret Management

- Jangan menyimpan Client Secret di Git repository
- Simpan seluruh credential pada Vaultwarden
- Gunakan secret yang unik untuk setiap aplikasi

---

## Enable MFA

Sangat disarankan untuk mengaktifkan MFA pada administrator Authentik:

```
User Settings
 ↓
Authenticator
 ↓
Add Authenticator
```

Contoh:

- TOTP
- Security Key (WebAuthn)

---

## Restrict Access

Gunakan Authentik Policies untuk:

- Membatasi aplikasi berdasarkan user/group
- Membuat role administrator
- Mengatur akses internal service

---

# Verification

## Test OIDC Discovery

Buka:

```
https://auth.homelab.local/application/o/<application-slug>/
```

Contoh:

```
https://auth.homelab.local/application/o/outline/
```

Pastikan response menampilkan JSON dengan informasi seperti:

```json
{
  "authorization_endpoint": "https://auth.homelab.local/application/o/authorize/"
}
```

---

## Common Issues

### Invalid redirect_uri

Penyebab:

- Redirect URI pada aplikasi tidak sama dengan Authentik Provider

Solusi:

- Periksa kembali Redirect URI di kedua sisi

---

### Login redirect loop

Penyebab umum:

- URL aplikasi menggunakan HTTP
- Reverse proxy tidak meneruskan header dengan benar
- Cookie domain tidak sesuai

Periksa:

- HTTPS aktif pada NPM
- Environment variable URL aplikasi

---

### Unable to resolve auth.homelab.local

Penyebab:

Container tidak menggunakan Pihole sebagai DNS.

Solusi:

Tambahkan DNS pada Docker Compose:

```yaml
dns:
  - 192.168.100.101
```

Contoh:

```yaml
services:
  application:
    dns:
      - 192.168.100.101
```

---

# Maintenance Checklist

Setelah menambahkan aplikasi baru:

- [ ] OIDC Provider dibuat
- [ ] Application dibuat di Authentik
- [ ] Client ID disimpan di Vaultwarden
- [ ] Client Secret disimpan di Vaultwarden
- [ ] Redirect URI sudah benar
- [ ] HTTPS melalui NPM aktif
- [ ] Login SSO berhasil

---

# Related Documents

- `lxc-104-auth.md`
- `outline-deployment.md`
- `postiz-deployment.md`
- `vaultwarden-deployment.md`

---

*Last updated: 2026-06-19*