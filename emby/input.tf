
variable "dc" {
  description = "data centers that the job runs in"
  type        = string
}

variable "namespace" {
  description = "namespace that the job runs in"
  type        = string
  default     = "default"
}

variable "enabled" {
  type        = bool
  description = "If false, then no job is deployed"
  default     = true
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "emby"
}

variable "service_provider" {
  description = "Service provider (consul or nomad)"
  type        = string
  default     = "nomad"
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

variable "host" {
  description = "host constraint for emby"
  type        = string
}

variable "port" {
  description = "port for emby"
  type        = number
  default     = 8096
}

variable "data" {
  description = "data volume for persistent data"
  type        = string
  default     = "/var/lib/emby"
}

variable "media" {
  description = "media volumes for media files"
  type        = list(string)
  default     = []
}

variable "devices" {
  description = "devices"
  type        = list(string)
  default     = ["/dev/dri", "/dev/vchiq", "/dev/video10", "/dev/video11", "/dev/video12"]
}

variable "timezone" {
  description = "timezone"
  type        = string
  default     = "Europe/Berlin"
}

variable "memory" {
  description = "memory reserved in MB"
  type        = number
  default     = 2048
}

