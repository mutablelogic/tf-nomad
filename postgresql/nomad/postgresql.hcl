
// postgres database server
// Docker Image: https://hub.docker.com/timescale/timescaledb

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

variable "hosts" {
  description = "host constraint for the job"
  type        = list(string)
  default     = []
}

variable "service_provider" {
  description = "Service provider, either consul or nomad"
  type        = string
  default     = "nomad"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "postgresql"
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

variable "docker_image" {
  description = "Docker image"
  type        = string
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

variable "port" {
  description = "Port for connections"
  type        = number
  default     = 5432
}

variable "data" {
  description = "Data persistence directory"
  type        = string
}

variable "root_password" {
  description = "root password"
  type        = string
}

variable "database" {
  description = "default database"
  type        = string
  default     = "default"
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  data_path = var.data == "" ? "${NOMAD_ALLOC_DIR}/data" : "/var/lib/postgresql"
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "postgresql" {
  type        = var.service_type
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "postgresql" {
    count = (length(var.hosts) == 0 || var.service_type == "system") ? 1 : length(var.hosts)

    dynamic "constraint" {
      for_each = length(var.hosts) == 0 ? [] : [join(",", var.hosts)]
      content {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = constraint.value
      }
    }

    network {
      port "postgresql" {
        static = var.port
        to     = 5432
      }
    }

    service {
      tags     = ["postgresql","postgres"]
      name     = var.service_name
      port     = "postgresql"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = true
    }

    task "server" {
      driver = "docker"

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["postgresql"]
        dns_servers = var.service_dns
        volumes = compact([
          var.data == "" ? "" : format("%s:/var/lib/postgresql", var.data)
        ])
      }

      env {
        POSTGRES_USER     = "root"
        POSTGRES_PASSWORD = var.root_password
        POSTGRES_DB       = var.database
        PGDATA            = local.data_path
      }

    } // task "server"
  }   // group "postgresql"
}     // job "postgresql"
