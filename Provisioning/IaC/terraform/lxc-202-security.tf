resource "proxmox_virtual_environment_container" "lxc_202" {
  node_name    = var.node_name
  vm_id        = 202
  description  = "Security — Vaultwarden"
  tags         = ["homelab", "security"]
  unprivileged = true
  started      = true

  startup {
    order      = 2
    up_delay   = 20
  }

  initialization {
    hostname = "security"

    dns {
      domain  = var.search_domain
      servers = [var.dns_server]
    }

    ip_config {
      ipv4 {
        address = "192.168.100.202/24"
        gateway = var.gateway
      }
    }

    user_account {
      keys     = [var.ssh_public_key]
      password = var.ct_password
    }
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 256
    swap      = 256
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  operating_system {
    template_file_id = "local:vztmpl/${var.template_name}.tar.zst"
    type             = "ubuntu"
  }

  features {
    nesting = true
  }
}
