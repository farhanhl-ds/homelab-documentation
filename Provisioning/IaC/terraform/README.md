# Terraform — Homelab LXC Provisioning

Provisioning seluruh LXC homelab di Proxmox menggunakan [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) provider.

## Prerequisites

### 1. Install Terraform

```bash
# Ubuntu / Debian
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
```

### 2. Buat Terraform User di Proxmox

Di Proxmox UI → Datacenter → Permissions → Users → Add:

| Field | Value |
|---|---|
| User | `terraform@pve` |
| Realm | `pve` (Proxmox VE authentication) |

Beri role `PVEVMAdmin` (cukup buat manage VM/LXC, tidak full admin):
Datacenter → Permissions → Permissions → Add → User Permission:

| Field | Value |
|---|---|
| Path | `/` |
| User | `terraform@pve` |
| Role | `PVEVMAdmin` |
| Propagate | ✅ |

Lalu generate API Token:
Datacenter → Permissions → API Tokens → Add:

| Field | Value |
|---|---|
| User | `terraform@pve` |
| Token ID | `terraform` |
| Privilege Separation | ✅ (centang, karena role sudah di-assign manual di atas) |

Simpan Token ID + Secret yang muncul (hanya tampil sekali) — formatnya `terraform@pve!terraform=<secret-uuid>`.

### 3. Download Ubuntu 24.04 Template

Di Proxmox UI → haytham-clone → local → CT Templates → Templates → cari `ubuntu-24.04-standard` → Download.

### 4. Setup tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # isi credential
```

## Usage

```bash
# Inisialisasi provider
terraform init

# Preview perubahan
terraform plan

# Apply — buat seluruh LXC
terraform apply

# Hapus seluruh LXC (hati-hati!)
terraform destroy
```

## Struktur File

```
terraform/
├── providers.tf               # Provider config
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values
├── lxc-101-core-infra.tf      # LXC 101
├── lxc-102-security.tf        # LXC 102
├── lxc-103-database.tf        # LXC 103
├── lxc-104-auth.tf            # LXC 104
├── lxc-105-productivity.tf    # LXC 105
├── terraform.tfvars.example   # Template credential
└── .gitignore                 # Exclude state & tfvars
```

## Catatan

- `terraform.tfvars` tidak boleh di-commit ke Git — sudah ada di `.gitignore`
- `terraform.tfstate` menyimpan state infrastruktur — simpan backup-nya
- Setelah `terraform apply`, lanjutkan ke Ansible untuk konfigurasi dan deployment service
