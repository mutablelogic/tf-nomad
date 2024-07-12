
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
  default     = "mongodb"
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
  default     = 27017
}

variable "data" {
  type        = string
  description = "Directory for data persistence"
  default     = ""
}

variable "admin_password" {
  description = "password for 'admin' user (required)"
  type        = string
  sensitive   = true
}

variable "replicaset_name" {
  description = "replica set name"
  type        = string
  default    = "rs0"
}


