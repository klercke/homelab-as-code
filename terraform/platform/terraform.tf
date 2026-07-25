terraform {
  required_version = "~> 1.10"

  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 5.7"
    }

    powerdns = {
      source  = "pan-net/powerdns"
      version = "~> 1.5"
    }
  }

  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/65683602/terraform/state/platform"
    lock_address   = "https://gitlab.com/api/v4/projects/65683602/terraform/state/platform/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/65683602/terraform/state/platform/lock"
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
}

provider "powerdns" {
  # api_key comes from PDNS_API_KEY
  server_url = "http://10.0.20.12:8081"
}
