
// InfluxDB time-series database
// Docker Image: https://hub.docker.com/_/influxdb

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
  description = "Port for plaintext connections"
  type        = number
  default     = 8086
}

variable "data" {
  description = "Data persistence directory (optional)"
  type        = string
  default     = ""
}

variable "organization" {
  description = "Organization name (required)"
  type        = string
}

variable "bucket" {
  description = "Default bucket name (required)"
  type        = string
}

variable "admin_password" {
  description = "Admin password (required)"
  type        = string
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  DATA_PATH = var.data == "" ? "${NOMAD_ALLOC_DIR}/data" : "/var/lib/influxdb"
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "influxdb" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "influxdb" {
    count = length(var.hosts)

    constraint {
      attribute = node.unique.name
      operator  = "set_contains_any"
      value     = join(",", var.hosts)
    }

    network {
      port "http" {
        static = var.port
        to     = 8086
      }
    }

    service {
      tags     = ["influxdb", "http"]
      name     = "influxdb-http"
      port     = "http"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = true
    }

    task "daemon" {
      driver = "docker"

      meta {
        data_path = local.DATA_PATH
      }

      template {
        destination = "local/config/config.yml"
        data        = <<-EOF
            secret-store: bolt
            engine-path: {{ env "NOMAD_META_data_path" }}/engine
            bolt-path: {{  env "NOMAD_META_data_path"  }}/influxd.bolt
            sqlite-path: {{ env "NOMAD_META_data_path" }}/influxd.sqlite
            http-bind-address: :8086
            ui-disabled: false
        EOF
      }

      config {
        image      = var.docker_image
        force_pull = var.docker_always_pull
        volumes = compact([
          var.data == "" ? "" : format("%s:/var/lib/influxdb", var.data),
          "local/config:/etc/influxdb2",
        ])
        ports = ["http"]
      }

      env {
        DOCKER_INFLUXDB_INIT_MODE     = "setup"
        DOCKER_INFLUXDB_INIT_USERNAME = "admin"
        DOCKER_INFLUXDB_INIT_PASSWORD = var.admin_password
        DOCKER_INFLUXDB_INIT_ORG      = var.organization
        DOCKER_INFLUXDB_INIT_BUCKET   = var.bucket
      }

    } // task "daemon"
  }   // group "influxdb"
}     // job "influxdb"
