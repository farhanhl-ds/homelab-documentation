# VS Code Remote SSH Setup

Panduan menggunakan VS Code Remote SSH untuk mengakses dan mengelola Proxmox host maupun LXC secara langsung dari desktop.

---

## Overview

VS Code Remote SSH memungkinkan editing file secara langsung pada server menggunakan VS Code lokal.

Workflow:

```text
VS Code Desktop
        |
Remote SSH Extension
        |
SSH Connection
        |
Proxmox Host / LXC
        |
Edit file, terminal, Docker management
```

Keuntungan:

- Editing file dengan GUI dibanding `nano`/`vim`
- Integrated terminal
- Syntax highlighting untuk YAML, Docker Compose, dan shell script
- Search dan navigation lebih mudah
- Extension VS Code dapat berjalan langsung di remote host

---

## Prerequisites

- VS Code terinstall
- Extension **Remote - SSH** terinstall
- SSH service aktif pada target server
- User memiliki akses SSH

---

## Generate SSH Key (Client)

Cek apakah SSH key sudah tersedia:

### Linux / macOS

```bash
ls ~/.ssh
```

### Windows PowerShell

```powershell
Get-ChildItem $env:USERPROFILE\.ssh
```

Apabila belum ada key:

```bash
ssh-keygen -t ed25519 -C "homelab-admin"
```

Lokasi default:

### Linux / macOS

```
~/.ssh/id_ed25519
```

### Windows

```
%USERPROFILE%\.ssh\id_ed25519
```

> ⚠️ Jangan menyimpan private key (`id_ed25519`) ke Git repository atau membagikannya kepada orang lain.
>
> Hanya public key (`id_ed25519.pub`) yang boleh disalin ke server.

---

## Temporary Password Login

Untuk server baru yang belum memiliki SSH key:

1. Enable password authentication sementara:

```bash
nano /etc/ssh/sshd_config
```

Pastikan:

```text
PasswordAuthentication yes
```

Restart SSH:

```bash
systemctl restart ssh
```

---

## Copy Public Key ke Server

Dari client:

### Linux / macOS

```bash
ssh-copy-id user@server-ip
```

### Windows PowerShell

Copy isi:

```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub
```

Kemudian pada server:

```bash
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
```

Paste public key lalu set permission:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

## Disable Password Authentication

Setelah SSH key berhasil:

```bash
nano /etc/ssh/sshd_config
```

Ubah:

```text
PasswordAuthentication no
```

Restart SSH:

```bash
systemctl restart ssh
```

---

# SSH Config

Edit file:

### Linux / macOS

```bash
nano ~/.ssh/config
```

### Windows

```powershell
notepad $env:USERPROFILE\.ssh\config
```

Contoh konfigurasi:

```sshconfig
Host proxmox
    HostName 192.168.100.10
    User root
    IdentityFile ~/.ssh/id_ed25519


Host core-infra
    HostName 192.168.100.101
    User root
    IdentityFile ~/.ssh/id_ed25519

Host security
    HostName 192.168.100.102
    User root
    IdentityFile ~/.ssh/id_ed25519

Host database
    HostName 192.168.100.103
    User root
    IdentityFile ~/.ssh/id_ed25519

Host auth
    HostName 192.168.100.104
    User root
    IdentityFile ~/.ssh/id_ed25519

Host productivity
    HostName 192.168.100.105
    User root
    IdentityFile ~/.ssh/id_ed25519

Host social
    HostName 192.168.100.106
    User root
    IdentityFile ~/.ssh/id_ed25519
```

> Sesuaikan `HostName` dengan IP Proxmox dan LXC yang digunakan.

---

## Connect dari VS Code

1. Buka VS Code
2. Tekan `Ctrl + Shift + P`
3. Pilih:

```
Remote-SSH: Connect to Host
```

4. Pilih host yang sudah dibuat pada SSH config.

Contoh:

```
productivity
```

VS Code akan menginstall **VS Code Server** pada host secara otomatis saat koneksi pertama.

---

## Daily Workflow

Contoh membuka stack Docker:

```bash
cd /opt/stacks
```

Struktur:

```text
/opt/stacks
├── pihole
├── npm
├── homepage
├── uptime-kuma
├── portainer
├── vaultwarden
├── database
├── authentik
├── outline
├── stirling-pdf
└── postiz
```

Contoh edit file:

```bash
/opt/stacks/outline/.env
```

Perubahan dapat dilakukan langsung dari VS Code editor.

---

## Verify SSH Connection

Coba login tanpa password:

```bash
ssh productivity
```

Expected:

```text
root@productivity:~#
```

Apabila masih meminta password:

- Pastikan `authorized_keys` benar
- Periksa permission `.ssh`
- Periksa `sshd_config`
- Restart service SSH

---

## Security Recommendations

- Gunakan SSH key dibanding password
- Disable password authentication setelah setup selesai
- Jangan menyimpan private key di repository Git
- Gunakan passphrase untuk SSH key apabila memungkinkan
- Batasi akses SSH hanya pada jaringan internal atau Tailscale

---

## Related Documents

- `create-lxc.md`
- `tailscale-setup.md`
- `backup-restore.md`

---

*Last updated: 2026-06-19*