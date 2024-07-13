
///////////////////////////////////////////////////////////////////////////////
// VARIABLES

variable "dc" {
  description = "data center that the job is eligible to run in"
  type        = string
}

variable "namespace" {
  description = "namespace that the job runs in"
  type        = string
  default     = "default"
}

variable "enabled" {
  type        = bool
  description = "If false, then no job is deployed"
  default     = true
}

variable "hosts" {
  description = "List of hosts to deploy on. If empty, one allocation will be created"
  type        = list(string)
  default     = []
}

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "nginx-ssl"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "docker_tag" {
  type        = string
  description = "Version of the docker image to use, defaults to latest"
  default     = "latest"
}

///////////////////////////////////////////////////////////////////////////////

variable "ports" {
  description = "Ports to expose"
  type        = map(number)
  default = {
    "http"  = 80,
    "https" = 443
  }
}

variable "servers" {
  description = "Servers configuration for nginx"
  type        = map(string)
}

variable "timezone" {
  description = "Timezone"
  type        = string
  default     = "Europe/Berlin"
}

variable "zone" {
  description = "zone"
  type        = string
}

variable "email" {
  description = "Email address for zone administator"
  type        = string
}

variable "subdomains" {
  description = "Subdomains. Leave empty to use a wildcard certificate"
  type        = list(string)
  default     = []
}

variable "dns_validation" {
  description = "DNS validation type (http, cloudflare, duckdns)"
  type        = string
  default     = "http"
}

variable "cloudflare_api_key" {
  description = "Cloudflare API key (when dns_validation is cloudflare)"
  type        = string
  default     = ""
}

variable "staging" {
  description = "Use let's encrypt staging environment"
  type        = bool
  default     = false
}
