
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

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "coredns-dns"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "service_type" {
  description = "Run as a service or system"
  type        = string
  default     = "service"
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
  sensitive   = true
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
