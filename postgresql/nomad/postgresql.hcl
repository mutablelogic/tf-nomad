
// postgres database server
// Docker Image: https://hub.docker.com/_/postgres

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
// JOB

job "postgresql" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "postgresql" {
    count = length(var.hosts)

    constraint {
      attribute = node.unique.name
      operator  = "set_contains_any"
      value     = join(",", var.hosts)
    }

    network {
      port "postgresql" {
        static = var.port
        to     = 5432
      }
    }

    service {
      tags     = ["postgresql"]
      name     = "postgresql"
      port     = "postgresql"
      provider = var.service_provider
    }

    task "server" {
      driver = "docker"

      config {
        image      = var.docker_image
        force_pull = var.docker_always_pull
        ports = ["postgresql"]
        volumes = compact([
          format("%s:/var/lib/postgresql", var.data == "" ? "" : var.data)
        ])
      }

      env {
        POSTGRES_USER     = "root"
        POSTGRES_PASSWORD = var.root_password
        POSTGRES_DB       = var.database
        PGDATA            = var.data == "" ? format("%s/data",NOMAD_ALLOC_DIR) : "/var/lib/postgresql/data"
      }

    } // task "server"
  }   // group "postgresql"
}     // job "postgresql"
