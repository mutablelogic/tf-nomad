
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
  description = "Version of the docker image to use, defaults to 17-bookworm"
  default     = "17-bookworm"
}

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "postgres"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "primary" {
  type        = string
  description = "Host to deploy the primary database on"
}

variable "replicas" {
  type        = list(string)
  description = "Hosts to deploy read-only replica databases on"
  default     = []
}

variable "port" {
  type        = number
  description = "Port to expose service for each database"
  default     = 5432
}

variable "database" {
  description = "Default database name"
  type        = string
  default     = "postgres"
}

variable "data" {
  type        = string
  description = "Directory for data persistence"
  default     = ""
}

variable "root_user" {
  description = "root user name"
  type        = string
  default     = "postgres"
}

variable "root_password" {
  description = "root password (required)"
  type        = string
  sensitive   = true
}

variable "replication_user" {
  description = "replication user name"
  type        = string
  default     = "replicator"
}

variable "replication_password" {
  description = "replication password (required)"
  type        = string
  sensitive   = true
}
