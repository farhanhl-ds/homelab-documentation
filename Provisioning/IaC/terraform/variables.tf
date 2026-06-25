# Proxmox connection
variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token (format: user@realm!tokenid=secret)"
  type        = string
  sensitive   = true
}

# Common config
variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "template_name" {
  description = "Ubuntu 24.04 LXC template"
  type        = string
  default     = "ubuntu-24.04-standard_24.04-2_amd64"
}

variable "gateway" {
  description = "Default gateway"
  type        = string
  default     = "192.168.100.1"
}

variable "dns_server" {
  description = "Default DNS server (Pihole)"
  type        = string
  default     = "192.168.100.201"
}

variable "search_domain" {
  description = "Search domain"
  type        = string
  default     = "homelab.local"
}

variable "ssh_public_key" {
  description = "SSH public key for root access"
  type        = string
}

variable "ct_password" {
  description = "Fallback root password for all LXC containers (SSH key tetap jadi metode login utama)"
  type        = string
  sensitive   = true
}
