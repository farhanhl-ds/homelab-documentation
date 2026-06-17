VM 100 menjalankan Home Assistant OS (HAOS) sebagai platform smart home automation.

## Specs

| | |
|---|---|
| VM ID | 100 |
| Hostname | home-assistant |
| OS | Home Assistant OS (HAOS) |
| CPU | 2 cores |
| RAM | 2048MB |
| Disk | 32GB |
| IP | 192.168.100.100/24 |
| URL | https://ha.homelab.local |

## Install

HAOS di-deploy via `.qcow2` image, bukan ISO installer biasa.

```bash
# Di Proxmox host — download HAOS image
wget -O /tmp/haos.qcow2.xz https://github.com/home-assistant/operating-system/releases/download/<version>/haos_ova-<version>.qcow2.xz
xz -d /tmp/haos.qcow2.xz

# Buat VM kosong via Proxmox UI, lalu import disk
qm importdisk 100 /tmp/haos.qcow2 local-lvm
```

Setelah import disk:
1. **VM → Hardware** → pilih disk yang diimport → Edit → set sebagai `scsi0`
2. **VM → Options → Boot Order** → set `scsi0` sebagai primary boot disk
3. Start VM

## Post-Deploy

1. Buka `http://192.168.100.100:8123` di browser
2. Ikuti onboarding wizard
3. Setup user dan aktifkan MFA (TOTP)
4. Setup NPM proxy host: `ha.homelab.local`

> HAOS melakukan update otomatis via **Settings → Updates** — tidak memerlukan update manual.

## Planned Integrations

| Add-on / Integration | Catatan |
|---|---|
| Mosquitto broker | MQTT broker untuk IoT devices |
| OwnTracks | Location tracking |
| Zigbee (ZHA atau Zigbee2MQTT) | TBD — tergantung dongle yang digunakan |

> **Zigbee:** USB dongle perlu di-passthrough ke VM via Proxmox USB passthrough. Tambahkan di **VM → Hardware** sebelum memulai setup Zigbee.

## Post-Deploy Checklist

- [ ] Download dan import HAOS image
- [ ] Onboarding + MFA setup
- [ ] Setup NPM proxy host: `ha.homelab.local`
- [ ] USB dongle passthrough (apabila menggunakan Zigbee)
- [ ] Setup Mosquitto broker

---

*Last updated: 2026-06-16*
