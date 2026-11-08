terraform {
  required_version = "~> 1.10"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.28"
    }
  }

  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/65683602/terraform/state/cloudflare"
    lock_address   = "https://gitlab.com/api/v4/projects/65683602/terraform/state/cloudflare/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/65683602/terraform/state/cloudflare/lock"
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

provider "cloudflare" {
  # api_token comes from CLOUDFLARE_API_TOKEN
}
