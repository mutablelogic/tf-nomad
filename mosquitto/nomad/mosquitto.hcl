
// Mosquitto MQTT broker
// Docker Image: https://hub.docker.com/_/eclipse-mosquitto

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
  description = "port"
  type        = number
  default     = 1883
}

variable "data" {
  description = "Data persistence directory, optional"
  type        = string
  default     = ""
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  DATA_PATH = var.data == "" ? "${NOMAD_ALLOC_DIR}/data" : "/mosquitto/data"
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "mosquitto" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  ///////////////////////////////////////////////////////////////////////////////

  group "mosquitto" {
    count = length(var.hosts)

    constraint {
      attribute = node.unique.name
      operator  = "set_contains_any"
      value     = join(",", var.hosts)
    }

    network {
      port "mqtt" {
        static = var.port
        to     = 1883
      }
    }

    service {
      tags     = ["mqtt"]
      name     = "mosquitto-mqtt"
      port     = "mqtt"
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
        destination = "/local/config/mosquitto.conf"
        data        = <<-EOF
          listener             1883
          allow_anonymous      true
          persistence          true
          persistence_location {{ env "NOMAD_META_data_path" }}
          log_dest             stderr
        EOF
      }

      config {
        image      = var.docker_image
        force_pull = var.docker_always_pull
        volumes = compact([
          var.data == "" ? "" : format("%s:/mosquitto/data",var.data),
          "local/config:/mosquitto/config:ro"
        ])
        ports = ["mqtt"]
      }
    }
  }
}
