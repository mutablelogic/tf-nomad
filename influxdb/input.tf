
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
  description = "List of hosts to deploy on (required)"
}

variable "port" {
  type        = number
  description = "Port to expose plaintext service"
  default     = 8086
}

variable "data" {
  type        = string
  description = "Directory for data persistence"
  default     = ""
}

variable "admin_password" {
  description = "Admin password (required)"
  type        = string
}

variable "organization" {
  description = "Organization name (required)"
  type        = string
}

variable "bucket" {
  description = "Default bucket"
  type        = string
  default     = "default"
}
