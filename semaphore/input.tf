
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
  default     = "semaphore"
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
  description = "List of hosts to deploy on"
  default     = []
}

variable "port" {
  type        = number
  description = "Port to expose plaintext service"
  default     = 3000
}

variable "admin_user" {
  description = "Admin user"
  type        = string
  default     = "Admin"
}

variable "admin_password" {
  description = "Admin password (required)"
  type        = string
  sensitive   = true
}

variable "db" {
  description = "Database parameters"
  type = object({
    type = string // postgres, mysql
    host = string
    port = number
    name = string
    user = string
  })
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "ldap" {
  description = "LDAP parameters"
  type = object({
    host          = string
    port          = number
    tls           = optional(bool)
    dn_bind       = string
    dn_search     = string
    filter_search = string
  })
  default = {
    host          = ""
    port          = 389
    tls           = false
    dn_bind       = ""
    dn_search     = ""
    filter_search = ""
  }
}

variable "ldap_password" {
  description = "LDAP password"
  type        = string
  sensitive   = true
}
