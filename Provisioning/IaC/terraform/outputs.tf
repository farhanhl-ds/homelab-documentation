output "lxc_ids" {
  description = "CT IDs seluruh LXC yang dibuat"
  value = {
    lxc_201_core_infra   = proxmox_virtual_environment_container.lxc_201.vm_id
    lxc_202_security     = proxmox_virtual_environment_container.lxc_202.vm_id
    lxc_203_database     = proxmox_virtual_environment_container.lxc_203.vm_id
    lxc_204_auth         = proxmox_virtual_environment_container.lxc_204.vm_id
    lxc_205_productivity = proxmox_virtual_environment_container.lxc_205.vm_id
  }
}

output "lxc_ips" {
  description = "IP address seluruh LXC"
  value       = local.ip
}
