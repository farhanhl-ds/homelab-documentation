# Infrastructure Issues

Troubleshooting masalah pada layer hardware, BIOS, dan Proxmox.

Masalah pada layer ini biasanya muncul sebelum LXC atau Docker dapat berjalan.

---

# Proxmox gagal boot setelah instalasi

## Symptoms

* Sistem masuk ke PXE / Network Boot.
* Muncul pesan `Secure Boot violation`.
* Proxmox berhasil boot tetapi VM atau LXC tidak dapat menggunakan virtualization features.

---

## Possible Causes

| Problem                                            | Root Cause                                                                 |
| -------------------------------------------------- | -------------------------------------------------------------------------- |
| Sistem masuk ke PXE boot                           | SSD atau disk instalasi Proxmox bukan prioritas utama pada BIOS boot order |
| `Secure Boot violation`                            | Secure Boot masih aktif dan tidak kompatibel dengan konfigurasi instalasi  |
| VM gagal dibuat atau virtualization tidak tersedia | Intel VT-x / VT-d belum diaktifkan pada BIOS                               |

---

# Diagnosis

## Check BIOS Boot Order

Masuk ke BIOS/UEFI saat startup.

Pastikan disk instalasi Proxmox berada pada urutan pertama:

```text
Boot Priority

1. SSD (Proxmox)
2. USB Device
3. Network / PXE
```

---

## Check Secure Boot Status

Masuk ke:

```text
BIOS → Security → Secure Boot
```

Pastikan:

```text
Secure Boot = Disabled
```

---

## Check Virtualization Features

Masuk ke:

```text
BIOS → CPU Configuration
```

Pastikan fitur berikut aktif:

```text
Intel Virtualization Technology (VT-x) = Enabled
Intel VT-d = Enabled
```

Untuk AMD, aktifkan fitur yang setara:

```text
SVM Mode = Enabled
IOMMU = Enabled
```

---

# Resolution

Lakukan perubahan BIOS sesuai hasil diagnosis:

* Pindahkan SSD Proxmox ke prioritas boot pertama.
* Disable Secure Boot apabila menyebabkan boot failure.
* Enable CPU virtualization (VT-x/VT-d atau AMD SVM/IOMMU).

Setelah melakukan perubahan:

1. Save BIOS configuration.
2. Restart server.
3. Pastikan Proxmox dapat melakukan boot dengan normal.

---

# Prevention

Sebelum instalasi Proxmox:

* Verifikasi mode boot yang digunakan (UEFI/Legacy).
* Pastikan virtualization CPU sudah aktif.
* Pastikan SSD target dipilih sebagai primary boot device.
* Dokumentasikan perubahan BIOS untuk maintenance berikutnya.

---

# Related Documents

* `Infrastructure/proxmox.md`
* `Nodes/`
* `Runbooks/Deployment/create-lxc.md`

---

*Last updated: 2026-06-20*
