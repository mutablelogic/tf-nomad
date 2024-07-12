
variable "dc" {
  type        = string
  description = "Data center name"
}

variable "namespace" {
  type        = string
  description = "Nomad namespace"
  default     = "default"
}

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "seaweedfs"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
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

variable "replication" {
  description = "Default replication"
  type        = string
  default     = "000"
}

variable "masters" {
  description = "Master servers"
  type = map(object({
    name = string           // Name for the nomad job
    data = optional(string) // Persisent data directories
  }))
}

variable "volumes" {
  description = "Volume servers"
  type = map(object({
    name       = string           // Name for the nomad job
    data       = list(string)     // Persisent data directories
    rack       = optional(string) // Rack name
    public_url = optional(string) // Publicly accessible address
  }))
}

variable "filers" {
  description = "Filer servers"
  type = map(object({
    name       = string           // Name for the nomad job
    data       = optional(string) // Persisent data directory
    rack       = optional(string) // Preferred rack to write data in
    collection = optional(string) // Use this collection name
    webdav     = optional(bool)   // Enable webdav
  }))
}

variable "metrics" {
  description = "Enable prometheus metrics ports"
  type        = bool
  default     = false
}

///////////////////////////////////////////////////////////////////////////////

variable "http_port_master" {
  description = "HTTP port for masters"
  type        = number
  default     = 9333
}

variable "grpc_port_master" {
  description = "gRPC port for masters, set as zero to use default"
  type        = number
  default     = 0
}

variable "metrics_port_master" {
  description = "Prometheus metrics port for masters"
  type        = number
  default     = 9090
}

variable "http_port_volume" {
  description = "HTTP port for volume servers"
  type        = number
  default     = 9334
}

variable "grpc_port_volume" {
  description = "gRPC port for volume servers, set as zero to use default"
  type        = number
  default     = 0
}

variable "metrics_port_volume" {
  description = "Prometheus metrics port for volume servers"
  type        = number
  default     = 9091
}

variable "http_port_filer" {
  description = "HTTP port for filer servers"
  type        = number
  default     = 9335
}

variable "grpc_port_filer" {
  description = "gRPC port for filer servers, set as zero to use default"
  type        = number
  default     = 0
}

variable "metrics_port_filer" {
  description = "Prometheus metrics port for filer servers"
  type        = number
  default     = 9092
}

variable "webdav_port_filer" {
  description = "Webdav port for filer servers"
  type        = number
  default     = 7333
}
