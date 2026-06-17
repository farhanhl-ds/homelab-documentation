Panduan umum pembuatan LXC Container di Proxmox. Alur ini sama untuk semua LXC — yang berbeda hanya spesifikasinya.

---

## Spec Reference

| LXC | CT ID | Hostname | IP | Disk | RAM | Swap |
|---|---|---|---|---|---|---|
| core-infra | 101 | core-infra | 192.168.100.101/24 | 8GB | 768MB | 512MB |
| security | 102 | security | 192.168.100.102/24 | 4GB | 256MB | 256MB |
| database | 103 | database | 192.168.100.103/24 | 16GB | 1024MB | 512MB |
| auth | 104 | auth | 192.168.100.104/24 | 16GB | 2048MB | 1024MB |
| productivity | 105 | productivity | 192.168.100.105/24 | 16GB | 1024MB | 512MB |

---

## Step by Step

### 1. Tab General

| Field | Value |
|---|---|
| Node | haytham |
| CT ID | *(sesuai tabel spec)* |
| Hostname | *(sesuai tabel spec)* |
| Unprivileged container | ✅ |
| Nesting | ✅ |
| Add to HA | ❌ |

### 2. Tab Template

| Field | Value |
|---|---|
| Storage | local |
| Template | ubuntu-24.04-standard_24.04-2_amd64 |

### 3. Tab Disks

| Field | Value |
|---|---|
| Storage | local-lvm |
| Disk size | *(sesuai tabel spec)* |

### 4. Tab CPU

| Field | Value |
|---|---|
| Cores | *(sesuai tabel spec)* |

### 5. Tab Memory

| Field | Value |
|---|---|
| Memory (MiB) | *(sesuai tabel spec)* |
| Swap (MiB) | *(sesuai tabel spec)* |

### 6. Tab Network

| Field | Value |
|---|---|
| IPv4 | Static |
| IPv4/CIDR | *(sesuai tabel spec)* |
| Gateway (IPv4) | 192.168.100.1 |
| IPv6/CIDR | None |
| Gateway (IPv6) | *(kosongkan)* |

> Gateway (IPv6) selalu dikosongkan — jangan diisi dengan `1.1.1.1` karena itu adalah DNS server, bukan IPv6 gateway.

### 7. Tab DNS

| Field | Value |
|---|---|
| DNS domain | homelab.local |
| DNS servers | 192.168.100.101 |

> **Pengecualian:** LXC 101 (core-infra) menggunakan `1.1.1.1` sebagai DNS — bukan Pihole. Lihat penjelasan lengkap di [network.md](../infrastructure/network.md).

### 8. Tab Confirm

Verifikasi seluruh value sudah sesuai spec. Centang **"Start after created"** → klik **Finish**.

---

## Post-Install Standard

Setelah LXC running, masuk via Proxmox UI → pilih LXC → Console:

```bash
apt update && apt upgrade -y
apt install curl -y
curl -fsSL https://get.docker.com | sh
```

Buat folder stacks sesuai LXC:

```bash
# LXC 101 — core-infra
mkdir -p /opt/stacks/{pihole,npm,homepage,uptime-kuma,portainer}

# LXC 102 — security
mkdir -p /opt/stacks/vaultwarden

# LXC 103 — database
mkdir -p /opt/stacks/database/init

# LXC 104 — auth
mkdir -p /opt/stacks/authentik

# LXC 105 — productivity
mkdir -p /opt/stacks/{outline,stirling-pdf,postiz}
```

> **Khusus LXC 101:** jalankan tambahan berikut untuk menonaktifkan `systemd-resolved` agar tidak konflik dengan Pihole di port 53:
> ```bash
> systemctl stop systemd-resolved
> systemctl disable systemd-resolved
> rm /etc/resolv.conf
> echo "nameserver 1.1.1.1" > /etc/resolv.conf
> ```

Setelah post-install selesai, lanjut ke deploy services di node file masing-masing.

---

*Last updated: 2026-06-16*
