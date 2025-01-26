
// certificate manager (actually part of service)
// docker pull ghcr.io/mutablelogic/go-service:latest

///////////////////////////////////////////////////////////////////////////////
// VARIABLES

variable "dc" {
  description = "data centers that the job is eligible to run in"
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
  default     = "certmanager"
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

///////////////////////////////////////////////////////////////////////////////

variable "hosts" {
  description = "hosts to deploy on"
  type        = list(string)
  default     = []
}

variable "port" {
  type        = number
  description = "Port to expose plaintext service"
  default     = 4333
}

variable "debug" {
  type        = bool
  description = "Debugging log output"
  default     = false
}

variable "database" {
  description = "Database connection parameters"
  type        = object({ host = string, port = number, name = string, user = string, ssl_mode = string })
  default     = { host : "", port : 0, name : "", user : "", ssl_mode : "" }
}

variable "database_password" {
  description = "Database password"
  type        = string
  default     = ""
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "certmanager" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "service" {
    count = length(var.hosts)

    constraint {
      attribute = node.unique.name
      operator  = "set_contains_any"
      value     = join(",", var.hosts)
    }

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    network {
      port "http" {
        static = var.port
        to     = 80
      }
    }

    service {
      tags     = ["certmanager", "http"]
      name     = var.service_name
      port     = "http"
      provider = var.service_provider
    }

    task "daemon" {
      driver = "docker"

      env {
        SERVICE_ENDPOINT = "http://0.0.0.0/"
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        dns_servers = var.service_dns
        ports       = ["http"]
        args = compact([
          "run",
          var.database.host == "" ? "" : format("--pg.host=%s", var.database.host),
          var.database.port == 0 ? "" : format("--pg.port=%d", var.database.port),
          var.database.name == "" ? "" : format("--pg.database=%s", var.database.name),
          var.database.user == "" ? "" : format("--pg.user=%s", var.database.user),
          var.database_password == "" ? "" : format("--pg.pass=%s", var.database_password),
          var.database.ssl_mode == "" ? "" : format("--pg.ssl-mode=%s", var.database.ssl_mode),
          var.debug ? "--debug" : "",
        ])
      }

    } // task "daemon"
  }   // group "service"
}     // job "taskmanager"
