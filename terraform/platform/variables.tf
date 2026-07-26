variable "env" {
  description = "The environment slug that this module operates under (prd, dev, lab)."
  type        = string
  default     = "prd"
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
