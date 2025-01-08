
///////////////////////////////////////////////////////////////////////////////
// VARIABLES

variable "dc" {
  description = "data centers that the job runs in"
  type        = list(string)
}

variable "namespace" {
  description = "namespace that the job runs in"
  type        = string
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
  default     = "metabase"
}

variable "service_dns" {
  description = "Service discovery DNS"
  type        = list(string)
  default     = []
}

variable "hosts" {
  description = "host constraint for the job, defaults to one host"
  type        = list(string)
  default     = []
}

variable "port" {
  description = "port for service"
  type        = number
  default     = 3000
}

variable "docker_image" {
  description = "Docker image"
  type        = string
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

variable "db" {
  description = "Database parameters"
  type = object({
    type = string // h2, postgres, mysql
    host = string
    port = number
    name = string
    user = string
  })
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = ""
}

variable "data" {
  description = "Persistent data path"
  type        = string
  default     = ""
}

variable "url" {
  description = "Url for connecting to metabase"
  type        = string
  default     = ""
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  filename = var.data == "" ? "" : "/data/metabase.db"
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "metabase" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  group "metabase" {
    count = length(var.hosts) == 0 ? 1 : length(var.hosts)

    dynamic "constraint" {
      for_each = length(var.hosts) == 0 ? [] : [join(",", var.hosts)]
      content {
        attribute = constraint.value
        operator  = "set_contains_any"
        value     = node.unique.name
      }
    }

    network {
      mode = "host"
      port "http" {
        static = var.port
        to     = 3000
      }
    }

    service {
      tags     = ["http", var.service_name]
      name     = format("%s-http", var.service_name)
      port     = "http"
      provider = var.service_provider
    }

    task "metabase" {
      driver = "docker"

      // Reserve 2GB/4GB of memory
      resources {
        memory = 1024
        memory_max = 2048
      }

      env {
        MB_DB_TYPE   = var.db.type
        MB_DB_DBNAME = var.db.name == null ? "" : var.db.name
        MB_DB_HOST   = var.db.host == null ? "" : var.db.host
        MB_DB_PORT   = var.db.port == null ? "" : var.db.port
        MB_DB_USER   = var.db.user == null ? "" : var.db.user
        MB_DB_PASS   = var.db_password
        MB_DB_FILE   = local.filename
        MB_SITE_URL  = var.url
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        dns_servers = var.service_dns
        ports       = ["http"]
        volumes = compact([
          local.filename == "" ? "" : format("%s:/data", var.data)
        ])
      } // config
    }   // task "metabase"
  }     // group "metabase"
}
