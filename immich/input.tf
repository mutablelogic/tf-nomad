
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
  description = "Version of the docker image to use, defaults to release"
  default     = "release"
}

variable "docker_ml_runtime" {
  description = "Docker runtime for machine learning"
  type        = string
  default     = ""
}

variable "ml" {
  description = "Run the machine learning group. Set to false to use a machine learning server elsewhere (set its URL in the Immich admin settings)"
  type        = bool
  default     = true
}

variable "redis" {
  description = "External Redis server. When host is empty, a Redis task runs alongside the server"
  type        = object({ host = optional(string, ""), port = optional(number, 6379) })
  default     = {}
}

variable "memory" {
  description = "Memory allocation (MB) for the server, redis and machine learning tasks"
  type        = object({ server = optional(number, 4096), redis = optional(number, 300), ml = optional(number, 2048) })
  default     = {}
}

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "hosts" {
  type        = list(string)
  description = "A list of hosts that can be used to deploy on."
  default     = []
}

variable "mlhosts" {
  description = "machine learning hosts"
  type        = list(string)
  default     = []
}

variable "port" {
  type        = number
  description = "Port to expose plaintext service"
  default     = 2283
}

variable "data" {
  type        = string
  description = "Persistence directory for the service"
  default     = ""
}

variable "media" {
  description = "media volumes for media files (/data, /data1, etc)"
  type        = list(string)
  default     = []
}

variable "database" {
  description = "Database connection parameters"
  type        = object({ host = string, name = string, user = string, password = string, port = number, ssl_mode = string })
  default     = { host : "", name : "", user : "", password : "", port : 5432, ssl_mode : "prefer" }
}
