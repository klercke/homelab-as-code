tflint {
  required_version = "~> 0.59"
}

config {
  format = "default"
}

plugin "terraform" {
  enabled = true
  version = "0.9.1"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}
