
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
  description = "List of hosts to deploy on, deploys on a single host if empty"
}

variable "ports" {
  type        = map(number)
  description = "Ports to expose"
  default = {
    http  = 80,
    https = 443
  }
}

variable "servers" {
  description = "Servers configuration for nginx"
  type = list(object({
    name = string
    data = string
  }))
}
