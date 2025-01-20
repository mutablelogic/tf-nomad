
// postgres database server with primary/replica support
// Docker Image: https://github.com/mutablelogic/docker-postgres

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

variable "docker_image" {
  description = "Docker image"
  type        = string
}

variable "docker_always_pull" {
  description = "Pull docker image on every job restart"
  type        = bool
  default     = false
}

variable "primary" {
  description = "Primary database host"
  type        = string
}

variable "replicas" {
  description = "Replica (read-only) database hosts"
  type        = list(string)
  default     = []
}

variable "port" {
  description = "Port for connections"
  type        = number
  default     = 5432
}

variable "database" {
  description = "default database"
  type        = string
  default     = "default"
}

variable "data" {
  description = "Data persistence directory"
  type        = string
}

variable "root_user" {
  description = "root user"
  type        = string
  default     = "postgres"
}

variable "root_password" {
  description = "root password"
  type        = string
}

variable "replication_user" {
  description = "replication user"
  type        = string
  default     = ""
}

variable "replication_password" {
  description = "replication password"
  type        = string
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  data_path = var.data == "" ? "${NOMAD_ALLOC_DIR}/data" : "/var/lib/postgresql/data/pgdata"
  replication_slots = [ for host in var.replicas : format("replica-%s", host) ]
  replication_primary = format("host=%s port=%s", var.primary, var.port)
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "postgres" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////
  // PRIMARY

  group "primary" {
    constraint {
      attribute = node.unique.name
      value     = var.primary
    }

    network {
      port "postgres" {
        static = var.port
        to     = 5432
      }
    }

    resources {
      memory = 2048
    }

    service {
      tags     = ["postgres", "primary"]
      name     = var.service_name
      port     = "postgres"
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
        ports       = [ "postgres" ]
        dns_servers = var.service_dns
        volumes = compact([
          var.data == "" ? "" : format("%s:/var/lib/postgresql/data", var.data)
        ])
      }

      env {
        POSTGRES_USER     = var.root_user
        POSTGRES_PASSWORD = var.root_password
        POSTGRES_DB       = var.database
        PGDATA            = local.data_path
        POSTGRES_REPLICATION_USER = var.replication_user
        POSTGRES_REPLICATION_PASSWORD = var.replication_password
        POSTGRES_REPLICATION_SLOT = join(",",local.replication_slots)
      }
    }
  }

  /////////////////////////////////////////////////////////////////////////////////
  // REPLICAS
/*
  group "replica" {
    count = length(var.replicas)

    constraint {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = join(",",var.replicas)
    }

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    network {
      port "postgres" {
        static = var.port
        to     = 5432
      }
    }

    service {
      tags     = [ "postgres", "replica" ]
      name     = var.service_name
      port     = "postgres"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = false
    }

    task "server" {
      driver = "docker"

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["postgres"]
        dns_servers = var.service_dns
        volumes = compact([
          var.data == "" ? "" : format("%s:/var/lib/postgresql/data", var.data)
        ])
      }

      env {
        POSTGRES_USER                 = var.root_user
        POSTGRES_PASSWORD             = var.root_password
        POSTGRES_DB                   = var.database
        PGDATA                        = local.data_path
        POSTGRES_REPLICATION_PRIMARY  = local.replication_primary
        POSTGRES_REPLICATION_USER     = var.replication_user
        POSTGRES_REPLICATION_PASSWORD = var.replication_password
        POSTGRES_REPLICATION_SLOT     = format("replica-%s", node.unique.name)
      }
    } // task
  }  // group
*/
} // job 
