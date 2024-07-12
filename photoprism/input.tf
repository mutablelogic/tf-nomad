
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
  default     = "photoprism"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "host" {
  type        = string
  description = "Hosts to deploy on"
}

variable "port" {
  type        = number
  description = "Port to expose plaintext service"
  default     = 2342
}

variable "url" {
  description = "url for photoprism"
  type        = string
  default     = ""
}

variable "data" {
  description = "data volume for persistent data"
  type        = string
  default = "/var/lib/photoprism"
}

variable "import" {
  description = "Path to import folder on local filesystem"
  type = string
}

variable "originals" {
  description = "Path to original photos on local filesystem"
  type = string
}

variable "backup" {
  description = "Path to backup folder for SQL metadata"
  type = string
}

variable "mariadb_data" {
  type        = string
  description = "Directory for mariadb data persistence"
  default     = ""
}

variable "admin_user" {
  description = "admin user"
  type        = string
  default = "admin"
}

variable "admin_password" {
  description = "password for 'admin' user (required)"
  type        = string
  sensitive   = true
}
