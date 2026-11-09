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


variable "edge_proxy_host" {
  description = "The host key for the server proxying public services. Internal clients reach exposed names through it too."
  type        = string
  default     = "edge01"
}
