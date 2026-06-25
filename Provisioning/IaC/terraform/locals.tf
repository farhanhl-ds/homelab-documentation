locals {
  # IP address per LXC — single source of truth
  # Ubah di sini kalau IP berubah; outputs dan resource referensinya otomatis ikut
  ip = {
    lxc_201_core_infra   = "192.168.100.201"
    lxc_202_security     = "192.168.100.202"
    lxc_203_database     = "192.168.100.203"
    lxc_204_auth         = "192.168.100.204"
    lxc_205_productivity = "192.168.100.205"
  }
}
