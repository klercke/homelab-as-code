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
