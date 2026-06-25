resource "proxmox_virtual_environment_container" "lxc_203" {
  node_name    = var.node_name
  vm_id        = 203
  description  = "Database — PostgreSQL, Redis, Adminer"
  tags         = ["homelab", "database"]
  unprivileged = true
  started      = true

  startup {
    order      = 3
    up_delay   = 20
  }

  initialization {
    hostname = "database"

    dns {
      domain  = var.search_domain
      servers = [var.dns_server]
    }

    ip_config {
      ipv4 {
        address = "192.168.100.203/24"
        gateway = var.gateway
      }
    }

    user_account {
      keys     = [var.ssh_public_key]
      password = var.ct_password
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 1024
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 16
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
