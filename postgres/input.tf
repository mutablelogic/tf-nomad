
variable "dc" {
  type        = list(string)
  description = "Data center names"
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
  description = "Version of the docker image to use, defaults to 18-trixie"
  default     = "18-trixie"
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

variable "networks" {
  description = "Networks to bind ports to"
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
  default     = ""
}

variable "replication_password" {
  description = "replication password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "replication_network" {
  description = "Network to use for replication connections (defaults to first network)"
  type        = string
  default     = ""
}

variable "primary_memory" {
  description = "Memory allocation in MB for the primary task"
  type        = number
  default     = 2048
}

variable "replica_memory" {
  description = "Memory allocation in MB for each replica task"
  type        = number
  default     = 512
}

variable "ssl_cert" {
  description = "Host path to SSL certificate file"
  type        = string
  default     = ""
}

variable "ssl_key" {
  description = "Host path to SSL private key file"
  type        = string
  default     = ""
}

variable "ssl_ca" {
  description = "Host path to SSL CA certificate file (for client certificate verification)"
  type        = string
  default     = ""
}
