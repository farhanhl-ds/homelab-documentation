resource "proxmox_virtual_environment_container" "lxc_201" {
  node_name    = var.node_name
  vm_id        = 201
  description  = "Core Infrastructure — Pi-hole, NPM, Portainer, Homepage, Uptime Kuma"
  tags         = ["homelab", "core-infra"]
  unprivileged = true
  started      = true

  startup {
    order      = 1
    up_delay   = 30
  }

  initialization {
    hostname = "core-infra"

    dns {
      domain  = var.search_domain
      servers = ["1.1.1.1"] # Tidak menggunakan Pihole — circular dependency
    }

    ip_config {
      ipv4 {
        address = "192.168.100.201/24"
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
    dedicated = 768
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
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
    nesting = true # required for Docker
  }
}
