
// OpenLDAP server
// Docker Image: https://hub.docker.com/r/prom/prometheus/

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
  default     = "prometheus"
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

variable "debug" {
  description = "Debug output"
  type        = bool
  default     = false
}

///////////////////////////////////////////////////////////////////////////////

variable "port" {
  description = "Port for connections"
  type        = number
  default     = 9090
}

variable "data" {
  description = "Data persistence directory"
  type        = string
  default     = ""
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  config_path = format("%s/config", NOMAD_TASK_DIR)
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "prometheus" {
  type        = var.service_type
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "prometheus" {
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
      port "prometheus" {
        static = var.port
        to     = 9090
      }
    }

    service {
      tags     = ["prometheus"]
      name     = var.service_name
      port     = "prometheus"
      provider = var.service_provider
    }

    task "daemon" {
      driver = "docker"

      config {
        image       = var.docker_image
        force_pull  = var.docker_always_pull
        ports       = ["prometheus"]
        dns_servers = var.service_dns
        volumes = compact([
          var.data == "" ? "" : format("%s:/prometheus", var.data)
        ])
      }

    } // task "daemon"
  }   // group "prometheus"
}     // job "prometheus"
