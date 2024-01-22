
variable "dc" {
  type        = string
  description = "Data center name"
}

variable "namespace" {
  type        = string
  description = "Nomad namespace"
  default     = "default"
}

variable "enabled" {
  type        = bool
  description = "If false, then no job is deployed"
  default     = true
}

variable "docker_tag" {
  type        = string
  description = "Version of the docker image to use, defaults to latest"
  default     = "latest"
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
