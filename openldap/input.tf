
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
  description = "Directory for data persistence, required"
}

variable "ldif" {
  type        = string
  description = "Directory for additional ldif files, optional"
}

variable "schema" {
  type        = string
  description = "Directory for additional schema files, optional"
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
