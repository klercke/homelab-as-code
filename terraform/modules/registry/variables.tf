variable "registry_path" {
  description = "Path to the registries directory, relative to this module."
  type        = string
  default     = "../../../registries"
}

variable "domain" {
  description = "Internal DNS domain, with trailing dot."
  type        = string
  default     = "protonet.internal."
}

variable "env" {
  description = "Environment label for canonical names. Everything is prod right now."
  type        = string
  default     = "prd"
}
