variable "registry_path" {
  description = "Path to the registries directory relative to this module."
  type        = string
  default     = "../../../registries"
}

variable "domain" {
  description = "Internal DNS domain with trailing dot."
  type        = string
  default     = "protonet.internal."
}

variable "env" {
  description = "Environment label for canonical name."
  type        = string
  default     = "prd"
}

variable "class_digits" {
  description = <<-EOT
    First octet of an RFC 1918 supernet -> the digit prepended to net_id to form
    the 802.1Q VLAN ID. 10.x -> 1, 172.16.x -> 2, 192.168.x -> 3.
  EOT
  type        = map(number)
  default = {
    "10"  = 1
    "172" = 2
    "192" = 3
  }
}

variable "allowed_classes" {
  description = "Class digits a site may use. Anything else is rejected at plan time."
  type        = list(number)
  default     = [1]
}

variable "site_prefix_v4_bits" {
  description = "Prefix length every site supernet must carry."
  type        = number
  default     = 16
}

variable "vlan_prefix_v4_bits" {
  description = "Prefix length of each derived VLAN segment."
  type        = number
  default     = 24
}

variable "site_prefix_v6_bits" {
  description = "Prefix length every site IPv6 prefix must carry (the ISP delegation)."
  type        = number
  default     = 56
}

variable "vlan_prefix_v6_bits" {
  description = "Prefix length of each derived VLAN IPv6 segment."
  type        = number
  default     = 64
}

variable "gateway_host_octet" {
  description = "Host octet of the default gateway within each VLAN prefix."
  type        = number
  default     = 1

  validation {
    condition     = var.gateway_host_octet >= 1 && var.gateway_host_octet <= 254
    error_message = "gateway_host_octet must be 1-254."
  }
}

variable "static_range" {
  description = "Inclusive [first, last] host octets for statically addressed hosts."
  type        = list(number)
  default     = [10, 49]

  validation {
    condition = (
      length(var.static_range) == 2 &&
      var.static_range[0] >= 1 &&
      var.static_range[0] <= var.static_range[1] &&
      var.static_range[1] <= 254
    )
    error_message = "static_range must be [first, last] with 1 <= first <= last <= 254."
  }
}

variable "dhcp_v4_dynamic_range" {
  description = "Default inclusive [first, last] host octets for the DHCP dynamic pool."
  type        = list(number)
  default     = [100, 199]

  validation {
    condition = (
      length(var.dhcp_v4_dynamic_range) == 2 &&
      var.dhcp_v4_dynamic_range[0] >= 1 &&
      var.dhcp_v4_dynamic_range[0] <= var.dhcp_v4_dynamic_range[1] &&
      var.dhcp_v4_dynamic_range[1] <= 254
    )
    error_message = "dhcp_v4_dynamic_range must be [first, last] with 1 <= first <= last <= 254."
  }
}

variable "dhcp_v4_reservation_range" {
  description = "Default inclusive [first, last] host octets for DHCP reservations."
  type        = list(number)
  default     = [200, 249]

  validation {
    condition = (
      length(var.dhcp_v4_reservation_range) == 2 &&
      var.dhcp_v4_reservation_range[0] >= 1 &&
      var.dhcp_v4_reservation_range[0] <= var.dhcp_v4_reservation_range[1] &&
      var.dhcp_v4_reservation_range[1] <= 254
    )
    error_message = "dhcp_v4_reservation_range must be [first, last] with 1 <= first <= last <= 254."
  }
}
