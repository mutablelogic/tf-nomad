
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
  description = "Version of the docker image to use, defaults to v1.11.1"
  default     = "v1.11.1"
}

variable "hosts" {
  type        = list(string)
  description = "List of hosts to deploy on. If empty, one allocation will be created"
  default     = []
}

variable "port" {
  type        = number
  description = "Port to expose DNS service"
  default     = 53
}

variable "nomad_addr" {
  description = "Nomad address url for service discovery (required)"
  type        = string
}

variable "nomad_token" {
  description = "Nomad authentication token"
  type        = string
  default     = ""
}

variable "cache_ttl" {
  description = "Number of seconds to cache service discovery results"
  type        = number
  default     = 30
}

variable "dns_zone" {
  type        = string
  description = "DNS lookup zone (service.namespace.zone.)"
  default     = "nomad"
}
