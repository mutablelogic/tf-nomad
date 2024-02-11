
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

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "openldap-admin"
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
  description = "Port to expose plaintext service"
  default     = 5000
}

variable "url" {
  description = "LDAP server url"
  type        = string
}

variable "basedn" {
  description = "LDAP base distinguished name"
  type        = string
}

variable "admin_password" {
  description = "LDAP admin password"
  type        = string
  sensitive   = true
}

variable "organization" {
  description = "Organization name"
  type        = string
}

variable "domain" {
  description = "Organization domain"
  type        = string
}
