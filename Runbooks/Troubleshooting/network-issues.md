# Network Issues

Troubleshooting masalah konektivitas jaringan antar device dalam Homelab.

Masalah pada layer ini terjadi sebelum DNS, reverse proxy, atau aplikasi dapat diakses.

---

# Service tidak dapat dijangkau melalui IP Address

## Symptoms

* Service tidak dapat diakses menggunakan IP.
* `ping` ke server gagal.
* Website tidak dapat dibuka meskipun menggunakan alamat IP langsung.
* LXC tidak dapat berkomunikasi dengan device lain di jaringan.

---

# Possible Causes

| Problem                          | Root Cause                                         |
| -------------------------------- | -------------------------------------------------- |
| Tidak ada konektivitas ke server | LXC/VM mati atau jaringan fisik bermasalah         |
| IP address salah                 | Konfigurasi static IP tidak sesuai                 |
| Gateway salah                    | Traffic keluar subnet tidak dapat diteruskan       |
| Firewall memblokir koneksi       | Port atau protokol yang dibutuhkan tidak diizinkan |
| Service belum berjalan           | Container atau aplikasi target tidak aktif         |

---

# Diagnosis

## 1. Periksa status LXC / VM

Dari Proxmox host:

```bash
pct list
qm list
```

Pastikan status menunjukkan:

```text
running
```

---

## 2. Periksa konfigurasi IP

Di dalam LXC atau VM:

```bash
ip addr
ip route
```

Pastikan:

* IP address sesuai subnet Homelab (`192.168.100.0/24`).
* Gateway mengarah ke router (`192.168.100.1`).

Contoh:

```text
inet 192.168.100.101/24

default via 192.168.100.1
```

---

## 3. Test konektivitas dasar

### Ping gateway

```bash
ping 192.168.100.1
```

Jika gagal:

* Periksa konfigurasi network interface.
* Periksa bridge Proxmox.
* Periksa kabel atau koneksi Wi-Fi.

---

### Ping antar node Homelab

Contoh dari LXC:

```bash
ping 192.168.100.101
```

Jika gagal:

* Pastikan target LXC sedang running.
* Pastikan IP tidak konflik.
* Periksa firewall Proxmox atau firewall host.

---

## 4. Periksa service yang berjalan

Masuk ke node target:

### Untuk Docker container:

```bash
docker ps
```

Pastikan container memiliki status:

```text
Up
```

---

### Untuk service berbasis systemd:

```bash
systemctl status <service-name>
```

---

# Resolution

Lakukan perbaikan berdasarkan hasil diagnosis:

* Start LXC atau VM yang mati.
* Perbaiki konfigurasi IP atau gateway.
* Restart service yang gagal berjalan.
* Perbaiki firewall yang memblokir traffic.
* Pastikan Docker container memiliki status `Up`.

---

# Prevention

* Gunakan static IP untuk seluruh node Homelab.
* Dokumentasikan alokasi IP pada `Infrastructure/network.md`.
* Gunakan naming yang konsisten untuk LXC dan VM.
* Lakukan health check rutin setelah restart atau power outage.

---

# Related Documents

* `Infrastructure/network.md`
* `Infrastructure/proxmox.md`
* `Runbooks/Operations/health-check.md`
* `Runbooks/Operations/power-recovery.md`

---

*Last updated: 2026-06-20*
