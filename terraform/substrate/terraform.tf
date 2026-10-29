terraform {
  required_version = "~> 1.10"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.9"
    }
  }

  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/65683602/terraform/state/substrate"
    lock_address   = "https://gitlab.com/api/v4/projects/65683602/terraform/state/substrate/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/65683602/terraform/state/substrate/lock"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }

  encryption {
    # key_provider "pbkdf2" "main" is injected via TF_ENCRYPTION (see .envrc)
    method "aes_gcm" "main" {
      keys = key_provider.pbkdf2.main
    }
    state {
      method   = method.aes_gcm.main
      enforced = true
    }
    plan {
      method   = method.aes_gcm.main
      enforced = true
    }
  }
}

provider "proxmox" {
  # auth and endpoint comes from env vars (see .envrc)

  insecure = true # Still using self-signed cert for now
}
