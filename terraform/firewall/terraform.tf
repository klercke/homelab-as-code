terraform {
  required_version = "~> 1.10"

  required_providers {
    opnsense = {
      source  = "browningluke/opnsense"
      version = "~> 0.26.0"
    }
  }

  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/65683602/terraform/state/firewall"
    lock_address   = "https://gitlab.com/api/v4/projects/65683602/terraform/state/firewall/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/65683602/terraform/state/firewall/lock"
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

provider "opnsense" {
  # api_key and api_secret come from OPNSENSE_API_KEY and OPNSENSE_API_SECRET
  uri = "https://10.0.60.1"

  # fw01's web UI certificate is self-signed
  allow_insecure = true
}
