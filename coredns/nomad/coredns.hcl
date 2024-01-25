
// coredns for service discovery
// Docker Image: https://hub.docker.com/r/coredns/coredns/

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
  default     = 53
}

variable "corefile" {
  description = "Configuration file for coredns (required)"
  type        = string
}

variable "nomad_addr" {
  description = "Nomad address url for service discovery (required)"
  type        = string
}

variable "nomad_token" {
  description = "Nomad authentication token"
  type        = string
  default     = ""
}

variable "cache_ttl" {
  description = "Number of seconds to cache service discovery results"
  type        = number
  default     = 30
}

variable "dns_zone" {
  description = "DNS lookup zone"
  type        = string
  default     = "nomad"
}

///////////////////////////////////////////////////////////////////////////////
// LOCALS

locals {
  core_file = format("%s/data/Corefile", NOMAD_ALLOC_DIR)
}

///////////////////////////////////////////////////////////////////////////////
// JOB

job "coredns" {
  type        = "service"
  datacenters = var.dc
  namespace   = var.namespace

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    health_check     = "task_states"
  }

  /////////////////////////////////////////////////////////////////////////////////

  group "coredns" {
    count = length(var.hosts) == 0 ? 1 : length(var.hosts)

    dynamic "constraint" {
      for_each = length(var.hosts) == 0 ? [] : [join(",", var.hosts)]
      content {
        attribute = node.unique.name
        operator  = "set_contains_any"
        value     = constraint.value
      }
    }

    network {
      port "dns" {
        static = var.port
        to     = 53
      }
    }

    service {
      tags     = ["dns"]
      name     = "coredns-dns"
      port     = "dns"
      provider = var.service_provider
    }

    ephemeral_disk {
      migrate = true
    }

    task "daemon" {
      driver = "docker"

      template {
        destination = local.core_file
        data        = var.corefile
      }

      env {
        NOMAD_ADDR  = var.nomad_addr
        NOMAD_TOKEN = var.nomad_token
        CACHE_TTL   = var.cache_ttl
        DNS_ZONE    = var.dns_zone
      }

      config {
        image      = var.docker_image
        force_pull = var.docker_always_pull
        ports      = ["dns"]
        args       = ["coredns", "-conf", local.core_file]
      }

    } // task "daemon"
  }   // group "coredns"
}     // job "coredns"
