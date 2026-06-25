# Shutdown Procedure

Prosedur shutdown homelab secara terencana untuk maintenance hardware, pemadaman listrik yang sudah diketahui sebelumnya, atau perubahan infrastructure.

Tujuan prosedur ini adalah memastikan seluruh service berhenti secara graceful sehingga tidak terjadi database corruption, data loss, atau filesystem issue.

---

## Shutdown Order

Service harus dimatikan dengan urutan kebalikan dari dependency startup.

| Order | LXC | Role | Reason |
|---|---|---|---|
| 1 | LXC 105 | Productivity | Bergantung pada Authentik dan database |
| 2 | LXC 104 | Authentication | Bergantung pada PostgreSQL dan Redis |
| 3 | LXC 103 | Database | Menyimpan data seluruh service |
| 4 | LXC 102 | Security | Vaultwarden bergantung pada DNS |
| 5 | LXC 101 | Core Infrastructure | DNS dan reverse proxy harus dimatikan terakhir |

---

## Phase 1 — Notify Users

Apabila terdapat user lain yang menggunakan homelab:

- Informasikan jadwal maintenance.
- Pastikan tidak ada aktivitas penting yang sedang berjalan.
- Pastikan tidak ada proses upload atau perubahan data yang sedang berlangsung.

Untuk homelab personal, phase ini dapat dilewati.

---

## Phase 2 — Verify System Health

Login ke Proxmox host:

```bash
ssh root@192.168.100.10
```

Cek seluruh LXC:

```bash
pct list
```

Pastikan seluruh service dalam kondisi normal sebelum shutdown.

---

## Phase 3 — Graceful LXC Shutdown

Matikan LXC sesuai dependency order.

### LXC 105 — Productivity

```bash
pct shutdown 105
```

Tunggu hingga status:

```text
stopped
```

Verifikasi:

```bash
pct status 105
```

---

### LXC 104 — Authentication

```bash
pct shutdown 104
pct status 104
```

---

### LXC 103 — Database

```bash
pct shutdown 103
pct status 103
```

---

### LXC 102 — Security

```bash
pct shutdown 102
pct status 102
```

---

### LXC 101 — Core Infrastructure

```bash
pct shutdown 101
pct status 101
```

---

## Phase 4 — Verify All LXC Stopped

Jalankan:

```bash
pct list
```

Expected:

```text
VMID STATUS
101  stopped
102  stopped
103  stopped
104  stopped
105  stopped
```

---

## Phase 5 — Shutdown Proxmox Host

Setelah seluruh LXC berhenti:

```bash
shutdown -h now
```

Tunggu hingga Proxmox host benar-benar mati sebelum:

- Memutus listrik
- Mencabut kabel power
- Melakukan maintenance hardware

---

## Emergency Shutdown

Gunakan hanya apabila graceful shutdown gagal.

Force stop LXC:

```bash
pct stop <CT_ID>
```

Contoh:

```bash
pct stop 103
```

> ⚠️ Force stop dapat menyebabkan data corruption, terutama pada PostgreSQL atau service yang sedang melakukan write operation.

Apabila Proxmox tidak dapat diakses:

- Gunakan tombol power fisik sebagai opsi terakhir.
- Setelah host kembali menyala, jalankan `power-recovery.md` untuk melakukan pemeriksaan seluruh service.

---

## Shutdown Checklist

### Services

- [ ] LXC 105 berhenti
- [ ] LXC 104 berhenti
- [ ] LXC 103 berhenti
- [ ] LXC 102 berhenti
- [ ] LXC 101 berhenti

### Host

- [ ] Semua LXC berstatus `stopped`
- [ ] Tidak ada aktivitas disk yang berjalan
- [ ] Proxmox host dimatikan dengan `shutdown -h now`

---

## Important Notes

- Jangan melakukan hard power-off pada Proxmox ketika PostgreSQL atau Redis masih aktif.
- Selalu lakukan shutdown menggunakan urutan dependency terbalik.
- Setelah maintenance selesai, nyalakan kembali Proxmox dan ikuti `power-recovery.md`.

---

*Last updated: 2026-06-18*