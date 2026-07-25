variable "rocky9_image_url" {
  description = "The URL for the Rocky9 image."
  type        = string
}

variable "rocky9_image_sha256" {
  description = "The SHA256 sum of the Rocky9 image."
  type        = string
}

variable "datastore_id" {
  description = "The name of the datastore VM disks should be deployed in."
  type        = string
  default     = "local-zfs"
}

variable "bootstrap_resolver" {
  description = "The DNS resolver to use before the substrate is built."
  type        = string
  default     = "9.9.9.9"
}

variable "pbs_storage" {
  description = "The name of the PBS datastore to use for backups."
  type        = string
  default     = "pbs-wasabi"
}
