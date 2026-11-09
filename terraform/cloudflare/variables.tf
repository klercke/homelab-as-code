variable "env" {
  description = "The environment slug that this module operates under (prd, dev, lab)."
  type        = string
  default     = "prd"
}

variable "edge_proxy_host" {
  description = "The host key for the server that serves exposed names."
  type        = string
  default     = "edge01"
}
