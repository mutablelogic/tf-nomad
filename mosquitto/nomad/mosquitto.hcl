
// Mosquitto MQTT broker
// Docker Image: https://hub.docker.com/_/eclipse-mosquitto

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
  default     = "mosquitto-mqtt"
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
  CERTMANAGER_IMAGE = "ghcr.io/mutablelogic/go-service:latest"
  CERTMANAGER_SERVICE = "certmanager"
  CERTMANAGER_CERT = "${var.service_name}-${var.namespace}"
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "mosquitto" {
  type        = var.service_type
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  ///////////////////////////////////////////////////////////////////////////////

  group "mosquitto" {
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
      port "mqtt" {
        static = var.port
        to     = 1883
      }
    }

    service {
      tags     = ["mosquitto", "mqtt"]
      name     = var.service_name
      port     = "mqtt"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = true
    }

///////////////////////////////////////////////////////////////////////////////
/*
    task "certmanager" {
      driver = "docker"
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      meta {
        certmanager_service_name = local.CERTMANAGER_SERVICE
      }

      template {
        data        = <<-EOH
          {{ $service_name := env "NOMAD_META_certmanager_service_name" }}
          {{ range nomadService $service_name -}}
          SERVICE_ENDPOINT="http://{{ .Address }}:{{ .Port }}/"
          {{ end }}
        EOH
        destination = "tmp/config.env"
        env         = true
      }

      config {
        image       = local.CERTMANAGER_IMAGE
        force_pull  = false
        dns_servers = var.service_dns
        args        = [
          "cert", local.CERTMANAGER_CERT, "--pem"
        ]
      }
    } // task "certmanager"
*/
///////////////////////////////////////////////////////////////////////////////

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
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["mqtt"]
        dns_servers = var.service_dns
        volumes = compact([
          var.data == "" ? "" : format("%s:/mosquitto/data", var.data),
          "local/config:/mosquitto/config:ro"
        ])

      }
    } // task "daemon"
  } // group "mosquitto"
} // job "mosquitto"

