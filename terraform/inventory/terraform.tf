terraform {
  required_version = "~> 1.10"

  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 5.7"
    }
  }

  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/65683602/terraform/state/inventory"
    lock_address   = "https://gitlab.com/api/v4/projects/65683602/terraform/state/inventory/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/65683602/terraform/state/inventory/lock"
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

provider "netbox" {
  # api_token comes from NETBOX_API_TOKEN
  server_url           = "http://10.0.20.11"
  allow_insecure_https = false

  request_timeout = 60
}
