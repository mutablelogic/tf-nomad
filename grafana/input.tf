
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
  default     = "openldap-ldap"
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
  default     = 3000
}

variable "data" {
  type        = string
  description = "Directory for data persistence"
  default     = ""
}

variable "admin_user" {
  description = "Name for 'admin' user (optional)"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Password for 'admin' user (required)"
  type        = string
  sensitive   = true
}

variable "admin_email" {
  description = "Email for 'admin' user"
  type        = string
  default     = ""
}

variable "anonymous" {
  description = "Allow anonymous access"
  type        = bool
  default     = false
}

variable "database" {
  description = "Database connection parameters"
  type        = object({ type = string, host = string, port = number, name = string, user = string, password = string, ssl_mode = string })
  default     = { type : "", host : "", port : 0, name : "", user : "", password : "", ssl_mode : "" }
}

variable "domain" {
  description = "Domain used for serving the application"
  type        = string
  default     = ""
}
