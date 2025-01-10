terraform {
  required_version = "~> 1.6.2"

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.31.1"
    }
    njalla = {
      source  = "Sighery/njalla"
      version = "~> 0.10.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.2"
    }
  }
}

