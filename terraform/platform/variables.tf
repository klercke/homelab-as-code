variable "env" {
  description = "The environment slug that this module operates under (prd, dev, lab)."
  type        = string
  default     = "prd"
}

variable "internal_proxy_host" {
  description = "The host key for the server proxying internal services."
  type        = string
  default     = "caddy01"
}

variable "site_location" {
  description = "Per-site location information. Supplied via SOPS."
  type = map(object({
    latitude         = optional(number)
    longitude        = optional(number)
    physical_address = optional(string)
  }))
  default = {}
}
