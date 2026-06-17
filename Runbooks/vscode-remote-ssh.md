Panduan setup VS Code di desktop Windows untuk mengedit file langsung di LXC tanpa perlu copy-paste manual.

> **Digunakan untuk:** mengedit `docker-compose.yml`, config files, dan file lain di `/opt/stacks` dari VS Code desktop.

---

## Prerequisites

- VS Code terinstall di Windows
- LXC target berstatus running dan memiliki SSH server (`openssh-server`)
- Akses SSH ke Proxmox host `haytham`

---

## Step 1 — Install VS Code Extensions

Install keduanya dari Marketplace (`Ctrl+Shift+X`):

- **Remote - SSH** (by Microsoft) — core engine koneksi SSH
- **Remote Explorer** (by Microsoft) — sidebar UI untuk manage remote machines

---

## Step 2 — Generate SSH Key (apabila belum ada)

Cek di PowerShell:
```powershell
ls ~/.ssh/
```

Apabila belum ada `id_ed25519`, generate:
```powershell
ssh-keygen -t ed25519 -C "homelab"
```
Tekan Enter untuk semua prompt (default path, tanpa passphrase).

---

## Step 3 — Copy SSH Key ke LXC

Lakukan setiap kali LXC baru dibuat atau di-recreate.

### 3a. Enable password auth sementara (dari Proxmox host)
```bash
pct exec <CT_ID> -- sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
pct exec <CT_ID> -- sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
pct exec <CT_ID> -- systemctl restart ssh
```

### 3b. Set password root LXC
```bash
pct exec <CT_ID> -- passwd root
```

### 3c. Copy public key dari PowerShell Windows
```powershell
type ~/.ssh/id_ed25519.pub | ssh root@192.168.100.10x "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```
Masukkan password root saat diminta.

### 3d. Disable password auth kembali (dari Proxmox host)
```bash
pct exec <CT_ID> -- sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
pct exec <CT_ID> -- sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
pct exec <CT_ID> -- systemctl restart ssh
```

### 3e. Test koneksi
```powershell
ssh root@192.168.100.10x
```
Apabila langsung masuk tanpa password — setup berhasil.

---

## Step 4 — Setup SSH Config

Buka `C:\Users\Farhan\.ssh\config` (atau via `Ctrl+Shift+P` → "Remote-SSH: Open SSH Configuration File").

Tambahkan entry berikut:
```
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

> `Host` adalah alias yang muncul di dropdown VS Code. `HostName` adalah IP asli LXC.

---

## Step 5 — Connect VS Code

1. `Ctrl+Shift+P` → "Remote-SSH: Connect to Host" → pilih host
2. Pilih platform: **Linux**
3. Tunggu VS Code install server di LXC (pertama kali 1–3 menit, normal)
4. **Open Folder** → ketik `/opt/stacks` → OK

> **Selanjutnya:** klik ikon Remote Explorer di sidebar → pilih host → connect.

---

## Quick Reference — pct Commands

```bash
pct list                     # lihat semua LXC dan statusnya
pct start 101                # start LXC 101
pct stop 101                 # stop LXC 101
pct enter 101                # masuk shell LXC 101
pct exec 101 -- <command>    # jalankan command di LXC tanpa masuk shell
pct status 101               # cek status LXC 101
```

---

## Troubleshooting

**Permission denied saat copy SSH key**
→ Password auth masih disabled. Ikuti Step 3a–3b terlebih dahulu.

**VS Code meminta password saat connect**
→ SSH key belum ter-copy ke LXC, atau LXC di-recreate. Ulangi Step 3.

**SSH service inactive di LXC**
→ Normal — LXC menggunakan socket activation. SSH otomatis aktif saat ada koneksi masuk.

**Could not establish connection**
→ Pastikan LXC berstatus running (`pct status <ID>`), SSH config sudah benar, dan IP sesuai.

**LXC di-recreate**
→ `authorized_keys` di server akan hilang. Ulangi Step 3. SSH config di laptop tidak perlu diubah.

---

*Last updated: 2026-06-16*
