
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

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "openldap-ldap"
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

variable "hosts" {
  type        = list(string)
  description = "List of hosts to deploy on, defaults to one host"
  default     = []
}

variable "port" {
  type        = number
  description = "Port to expose plaintext service"
  default     = 389
}

variable "data" {
  type        = string
  description = "Directory for data persistence"
  default = ""
}

variable "admin_password" {
  description = "LDAP admin password (required)"
  type        = string
  sensitive   = true
}

variable "basedn" {
  description = "LDAP distinguished name (required)"
  type        = string
}

variable "organization" {
  description = "Organization name (required)"
  type        = string
}
