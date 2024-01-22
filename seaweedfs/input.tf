
variable "dc" {
  type        = string
  description = "Data center name"
}

variable "namespace" {
  type        = string
  description = "Namespace for the SeaweedFS cluster (optional)"
  default     = "default"
}

variable "enabled" {
  type        = bool
  description = "Whether to deploy the SeaweedFS cluster"
  default     = true
}

variable "masters" {
  type        = list(object)
  description = "List of master servers, needs to be an odd number, with elements: ip"
}

variable "volumes" {
  type        = list(object)
  description = "List of volume servers, with elements: ip, disks, max, rack"
}

variable "filers" {
  type        = list(object)
  description = "List of filer servers, with elements: ip"
}

variable "metrics" {
  type        = bool
  description = "Allocate a port on each server for pulling prometheus metrics"
  default     = false
}

variable "s3" {
  type        = bool
  description = "Enable S3 service on filers"
  default     = false
}

variable "webdav" {
  type        = bool
  description = "Enable WebDAV service on filers"
  default     = false
}
