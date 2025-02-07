
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
  description = "hosts to deploy on"
  type        = list(string)
  default     = []
}

variable "model" {
  type        = string
  description = "Model name"
}

variable "timeout" {
  type        = string
  description = "Client timeout"
}

variable "keys" {
  type        = map(string)
  description = "Environment variables"
  default     = {}
}

