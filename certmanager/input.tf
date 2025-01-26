
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
  description = "Version of the docker image to use"
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
  default     = "certmanager"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "debug" {
  description = "Debugging output"
  type        = bool
  default     = false
}

variable "hosts" {
  type        = list(string)
  description = "Hosts to deploy on"
}

variable "port" {
  type        = number
  description = "Port to expose plaintext service"
  default     = 4333
}

variable "database" {
  description = "Database connection parameters"
  type        = object({ host = string, port = number, name = string, user = string, ssl_mode = string })
  default     = { host : "", port : 0, name : "", user : "", ssl_mode : "" }
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = ""
}

