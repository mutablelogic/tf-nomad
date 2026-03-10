
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

variable "networks" {
  description = "Networks to bind ports to"
  type        = list(string)
  default     = []
}

variable "docker_image" {
  description = "Docker image"
  type        = string
}

variable "docker_tag" {
  description = "Docker image tag (e.g. 17-bookworm or 18-trixie)"
  type        = string
  default     = ""
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
  default     = ""
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
  default     = ""
}

variable "replication_network" {
  description = "Network to use for replication connections (defaults to first network, or no host_network if networks is empty)"
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
  description = "Host path to SSL CA certificate file"
  type        = string
  default     = ""
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  // PostgreSQL 18+ uses a different volume mount path
  data_mount_path             = tonumber(split("-", var.docker_tag)[0]) >= 18 ? "/var/lib/postgresql" : "/var/lib/postgresql/data"
  data_path                   = var.data == "" ? "/alloc/data" : "/var/lib/postgresql/data/pgdata"
  replication_slots           = [for host in var.replicas : format("replica_%s", host)]
  port_names                  = length(var.networks) > 0 ? [for n in var.networks : "postgres-${n}"] : ["postgres"]
  replication_network         = var.replication_network != "" ? var.replication_network : (length(var.networks) > 0 ? var.networks[0] : "")
  primary_replication_service = local.replication_network != "" ? format("%s-primary-%s", var.service_name, local.replication_network) : format("%s-primary", var.service_name)
  ssl_volumes = compact([
    var.ssl_cert != "" ? format("%s:/etc/ssl/postgres/server.crt", var.ssl_cert) : "",
    var.ssl_key != "" ? format("%s:/etc/ssl/postgres/server.key", var.ssl_key) : "",
    var.ssl_ca != "" ? format("%s:/etc/ssl/postgres/ca.crt", var.ssl_ca) : "",
  ])
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "postgres" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time  = "10s"
    healthy_deadline  = "5m"
    progress_deadline = "10m"
    health_check      = "checks"
  }

  /////////////////////////////////////////////////////////////////////////////////
  // PRIMARY

  group "primary" {
    constraint {
      attribute = node.unique.name
      value     = var.primary
    }

    // Ports without host_network (when networks is empty)
    dynamic "network" {
      for_each = length(var.networks) == 0 ? [1] : []
      content {
        port "postgres" {
          static = var.port
          to     = 5432
        }
      }
    }

    // Ports with host_network (when networks is specified)
    dynamic "network" {
      for_each = length(var.networks) > 0 ? [1] : []
      content {
        dynamic "port" {
          for_each = var.networks
          labels   = ["postgres-${port.value}"]
          content {
            static       = var.port
            to           = 5432
            host_network = port.value
          }
        }
      }
    }

    // Service without networks
    dynamic "service" {
      for_each = length(var.networks) == 0 ? [1] : []
      content {
        tags     = ["postgres", "primary"]
        name     = format("%s-primary", var.service_name)
        port     = "postgres"
        provider = var.service_provider

        check {
          type     = "tcp"
          port     = "postgres"
          interval = "15s"
          timeout  = "3s"
        }
      }
    }

    // Services with networks
    dynamic "service" {
      for_each = length(var.networks) > 0 ? {
        for network in var.networks : "postgres-${network}" => { network = network }
      } : {}
      content {
        name     = "${var.service_name}-primary-${service.value.network}"
        port     = service.key
        tags     = ["postgres", "primary", service.value.network]
        provider = var.service_provider

        check {
          type     = "tcp"
          port     = service.key
          interval = "15s"
          timeout  = "3s"
        }
      }
    }

    task "server" {
      driver = "docker"

      resources {
        memory = var.primary_memory
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = local.port_names
        dns_servers = var.service_dns
        volumes = concat(
          var.data != "" ? [format("%s:%s", var.data, local.data_mount_path)] : [],
          local.ssl_volumes
        )
      }

      env {
        POSTGRES_USER                 = var.root_user
        POSTGRES_PASSWORD             = var.root_password
        POSTGRES_DB                   = var.database
        PGDATA                        = local.data_path
        POSTGRES_REPLICATION_USER     = var.replication_user
        POSTGRES_REPLICATION_PASSWORD = var.replication_password
        POSTGRES_REPLICATION_SLOT     = join(",", local.replication_slots)
        POSTGRES_SSL_CERT             = var.ssl_cert != "" ? "/etc/ssl/postgres/server.crt" : ""
        POSTGRES_SSL_KEY              = var.ssl_key != "" ? "/etc/ssl/postgres/server.key" : ""
        POSTGRES_SSL_CA               = var.ssl_ca != "" ? "/etc/ssl/postgres/ca.crt" : ""
      }
    }
  }

  /////////////////////////////////////////////////////////////////////////////////
  // REPLICAS

  group "replica" {
    count = length(var.replicas)

    constraint {
      attribute = node.unique.name
      operator  = "set_contains_any"
      value     = join(",", var.replicas)
    }

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    // Ports without host_network (when networks is empty)
    dynamic "network" {
      for_each = length(var.networks) == 0 ? [1] : []
      content {
        port "postgres" {
          static = var.port
          to     = 5432
        }
      }
    }

    // Ports with host_network (when networks is specified)
    dynamic "network" {
      for_each = length(var.networks) > 0 ? [1] : []
      content {
        dynamic "port" {
          for_each = var.networks
          labels   = ["postgres-${port.value}"]
          content {
            static       = var.port
            to           = 5432
            host_network = port.value
          }
        }
      }
    }

    // Service without networks
    dynamic "service" {
      for_each = length(var.networks) == 0 ? [1] : []
      content {
        tags     = ["postgres", "replica"]
        name     = format("%s-replica", var.service_name)
        port     = "postgres"
        provider = var.service_provider

        check {
          type     = "tcp"
          port     = "postgres"
          interval = "15s"
          timeout  = "3s"
        }
      }
    }

    // Services with networks
    dynamic "service" {
      for_each = length(var.networks) > 0 ? {
        for network in var.networks : "postgres-${network}" => { network = network }
      } : {}
      content {
        name     = "${var.service_name}-replica-${service.value.network}"
        port     = service.key
        tags     = ["postgres", "replica", service.value.network]
        provider = var.service_provider

        check {
          type     = "tcp"
          port     = service.key
          interval = "15s"
          timeout  = "3s"
        }
      }
    }

    task "wait-for-primary" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      resources {
        memory = 64
      }

      meta {
        primary_replication_service = local.primary_replication_service
      }

      template {
        data        = <<-EOH
          {{ range nomadService (env "NOMAD_META_primary_replication_service") -}}
          POSTGRES_REPLICATION_PRIMARY="host={{ .Address }} port={{ .Port }}"
          {{ end -}}
        EOH
        destination = "local/config.env"
        env         = true
      }

      driver = "docker"
      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        command     = "pg_isready"
        args        = ["-d", "${POSTGRES_REPLICATION_PRIMARY}", "-t", "60"]
        dns_servers = var.service_dns
      }
    }

    task "server" {
      driver = "docker"

      resources {
        memory = var.replica_memory
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = local.port_names
        dns_servers = var.service_dns
        volumes = concat(
          var.data != "" ? [format("%s:%s", var.data, local.data_mount_path)] : [],
          local.ssl_volumes
        )
      }

      meta {
        primary_replication_service = local.primary_replication_service
      }

      template {
        data        = <<-EOH
          {{ range nomadService (env "NOMAD_META_primary_replication_service") -}}
          POSTGRES_REPLICATION_PRIMARY="host={{ .Address }} port={{ .Port }}"
          {{ end -}}
          POSTGRES_REPLICATION_SLOT="replica_{{ env "node.unique.name" }}"
        EOH
        destination = "local/config.env"
        env         = true
      }

      env {
        POSTGRES_USER                 = var.root_user
        POSTGRES_PASSWORD             = var.root_password
        POSTGRES_DB                   = var.database
        PGDATA                        = local.data_path
        POSTGRES_REPLICATION_USER     = var.replication_user
        POSTGRES_REPLICATION_PASSWORD = var.replication_password
        POSTGRES_SSL_CERT             = var.ssl_cert != "" ? "/etc/ssl/postgres/server.crt" : ""
        POSTGRES_SSL_KEY              = var.ssl_key != "" ? "/etc/ssl/postgres/server.key" : ""
        POSTGRES_SSL_CA               = var.ssl_ca != "" ? "/etc/ssl/postgres/ca.crt" : ""
      }
    } // task
  }   // group
}     // job 
