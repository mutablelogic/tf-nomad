
// grafana dashboard software
// Docker Image: grafana/grafana

///////////////////////////////////////////////////////////////////////////////
// VARIABLES

variable "dc" {
  description = "Data centers that the job is eligible to run in"
  type        = list(string)
}

variable "namespace" {
  description = "Namespace that the job runs in"
  type        = string
  default     = "default"
}

variable "hosts" {
  description = "Host constraint for the job, if empty exactly one allocation will be created"
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
  description = "Port for plaintext connections"
  type        = number
  default     = 3000
}

variable "data" {
  description = "Data persistence directory"
  type        = string
  default     = ""
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

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  logs_path =  "${NOMAD_ALLOC_DIR}/logs"
  data_path = var.data == "" ? "${NOMAD_ALLOC_DIR}/data/db" : "/var/lib/grafana/data"
  plugins_path = var.data == "" ? "${NOMAD_ALLOC_DIR}/data/plugins" : "/var/lib/grafana/plugins"
  provisioning_path = var.data == "" ? "${NOMAD_ALLOC_DIR}/data/provisioning" : "/var/lib/grafana/provisioning"
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "grafana" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "grafana" {
    count = length(var.hosts) == 0 ? 1 : length(var.hosts)

    dynamic "constraint" {
      for_each = length(var.hosts) == 0 ? [] : [ join(",", var.hosts) ]
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

    task "daemon" {
      driver = "docker"

      env {
        GF_PATHS_LOGS              = local.logs_path
        GF_PATHS_DATA              = local.data_path
        GF_PATHS_PLUGINS           = local.plugins_path
        GF_PATHS_PROVISIONING      = local.provisioning_path
        GF_SECURITY_ADMIN_USER     = "admin"
        GF_SECURITY_ADMIN_PASSWORD = var.admin_password
        GF_SECURITY_ADMIN_EMAIL    = var.admin_email
        GF_AUTH_ANONYMOUS_ENABLED  = var.anonymous_enabled
        GF_AUTH_ANONYMOUS_ORG_NAME = var.anonymous_org
        GF_AUTH_ANONYMOUS_ORG_ROLE = var.anonymous_role
        GF_AUTH_HIDE_VERSION       = true
      }

      config {
        image      = var.docker_image
        force_pull = var.docker_always_pull
        ports      = ["http"]
        volumes = compact([
          var.data == "" ? "" : format("%s:/var/lib/grafana", var.data)
        ])
      }

    } // task "daemon"

  } // group "grafana"

} // job "grafana"
