
// grafana dashboard software
// Docker Image: grafana/grafana

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

variable "hosts" {
  description = "host constraint for the job, defaults to one host"
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
  default     = "grafana-http"
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

///////////////////////////////////////////////////////////////////////////////

variable "port" {
  description = "Port for plaintext connections"
  type        = number
  default     = 3000
}

variable "data" {
  description = "Data persistence directory"
  type        = string
  default     = ""
}

variable "admin_user" {
  description = "Name for 'admin' user (optional)"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Password for 'admin' user (required)"
  type        = string
}

variable "admin_email" {
  description = "Email for 'admin' user"
  type        = string
  default     = ""
}

variable "anonymous_enabled" {
  description = "Allow anonymous access"
  type        = bool
  default     = false
}

variable "anonymous_org" {
  description = "Organization name that should be used for unauthenticated users"
  type        = string
  default     = ""
}

variable "anonymous_role" {
  description = "Role for unauthenticated users"
  type        = string
  default     = "Viewer"
}

variable "database" {
  description = "Database connection parameters"
  type        = object({ type = string, host = string, port = number, name = string, user = string, password = string, ssl_mode = string })
  default     = { type : "", host : "", port : 0, name : "", user : "", password : "", ssl_mode : "" }
}

variable "domain" {
  description = "Domain used for serving the application"
  type        = string
  default     = ""
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  logs_path         = "${NOMAD_ALLOC_DIR}/logs"
  db_path           = var.data == "" ? "${NOMAD_ALLOC_DIR}/data/db" : "/var/lib/grafana/data"
  plugins_path      = var.data == "" ? "${NOMAD_ALLOC_DIR}/data/plugins" : "/var/lib/grafana/plugins"
  provisioning_path = var.data == "" ? "${NOMAD_ALLOC_DIR}/data/provisioning" : "/var/lib/grafana/provisioning"
  db_host           = var.database.host == "" ? "" : format("%s:%d", var.database.host, var.database.port == 0 ? 5432 : var.database.port)
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "grafana" {
  type        = var.service_type
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "grafana" {
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
      port "http" {
        static = var.port
        to     = 3000
      }
    }

    service {
      tags     = ["grafana", "http"]
      name     = "grafana-http"
      port     = "http"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = true
    }

    task "init" {
      driver = "raw_exec"

      lifecycle {
        sidecar = false
        hook    = "prestart"
      }

      config {
        // Set permissions on the directory
        command = var.data == "" ? "/usr/bin/echo" : "/usr/bin/install"
        args = compact([
          "-d", var.data,
          "-o", "472"
        ])
      }
    } // task "init"

    task "daemon" {
      driver = "docker"

      env {
        GF_PATHS_LOGS              = local.logs_path
        GF_PATHS_DATA              = local.db_path
        GF_PATHS_PLUGINS           = local.plugins_path
        GF_PATHS_PROVISIONING      = local.provisioning_path
        GF_SECURITY_ADMIN_USER     = var.admin_user
        GF_SECURITY_ADMIN_PASSWORD = var.admin_password
        GF_SECURITY_ADMIN_EMAIL    = var.admin_email
        GF_AUTH_ANONYMOUS_ENABLED  = var.anonymous_enabled
        GF_AUTH_ANONYMOUS_ORG_NAME = var.anonymous_org
        GF_AUTH_ANONYMOUS_ORG_ROLE = var.anonymous_role
        GF_AUTH_HIDE_VERSION       = true
        GF_DATABASE_TYPE           = var.database.type
        GF_DATABASE_HOST           = local.db_host
        GF_DATABASE_NAME           = var.database.name
        GF_DATABASE_USER           = var.database.user
        GF_DATABASE_PASSWORD       = var.database.password
        GF_DATABASE_SSL_MODE       = var.database.ssl_mode
        GF_SERVER_DOMAIN           = var.domain
      }

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["http"]
        dns_servers = var.service_dns
        volumes = compact([
          var.data == "" ? "" : format("%s:/var/lib/grafana", var.data)
        ])
      }

    } // task "daemon"
  }   // group "grafana"
}     // job "grafana"
