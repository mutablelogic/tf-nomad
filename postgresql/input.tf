
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
  description = "List of hosts to deploy on, if not specified deploys to one node"
  default     = []
}

variable "port" {
  type        = number
  description = "Port to expose service"
  default     = 5432
}

variable "data" {
  type        = string
  description = "Directory for data persistence"
  default     = ""
}

variable "root_password" {
  description = "root password (required)"
  type        = string
  sensitive   = true
}

variable "database" {
  description = "Default database"
  type        = string
}
