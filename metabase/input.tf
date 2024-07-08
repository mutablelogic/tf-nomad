
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

variable "service_name" {
  description = "Name of service"
  type        = string
  default     = "metabase"
}

variable "hosts" {
  type        = list(string)
  description = "List of hosts to deploy on. If empty, one allocation will be created"
  default     = []
}

variable "port" {
  type        = number
  description = "Port for metabase"
  default     = 3001
}

variable "url" {
  description = "Url for connecting to metabase"
  type        = string
  default     = ""
}

variable "data" {
  description = "Data persistence directory, optional"
  type        = string
  default     = ""
}

variable "db" {
  description = "Database parameters"
  type = object({
    type     = string // h2, postgres, mysql
    host     = optional(string)
    port     = optional(number)
    name     = optional(string)
    user     = optional(string)
    filename = optional(string) // filename for h2 database
  })
  default = {
    type = "h2"
  }
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = ""
}

