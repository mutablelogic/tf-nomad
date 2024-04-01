
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

variable "access_token" {
  description = "Github access token"
  type        = string
  sensitive   = true
}

variable "organization" {
  description = "Github organization"
  type        = string
}

variable "name" {
  description = "Github runner name"
  type        = string
  default     = ""
}

variable "group" {
  description = "Github runner group"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Github runner labels"
  type        = list(string)
  default     = []
}

variable "data" {
  description = "Data persistence directory, optional"
  type        = string
  default     = ""
}
