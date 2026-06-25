resource "proxmox_virtual_environment_container" "lxc_205" {
  node_name    = var.node_name
  vm_id        = 205
  description  = "Productivity — Outline, Stirling PDF, Postiz"
  tags         = ["homelab", "productivity"]
  unprivileged = true
  started      = true

  startup {
    order      = 5
    up_delay   = 10
  }

  initialization {
    hostname = "productivity"

    dns {
      domain  = var.search_domain
      servers = [var.dns_server]
    }

    ip_config {
      ipv4 {
        address = "192.168.100.205/24"
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
