output "authentik_server_ip" {
  description = "The IP assigned to PTXE-LND-AUTH-01"
  value       = linode_instance.authentik.ip_address
}

